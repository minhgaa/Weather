// Polyfill fetch/Request/Response for Node environments where they may be missing,
// and to satisfy @sendgrid/client (axios) detection.
const nf = require('node-fetch'); // ensure node-fetch@2 is installed
global.fetch = nf;
global.Request = nf.Request;
global.Response = nf.Response;

const admin = require('firebase-admin');

const sgMail = require("@sendgrid/mail");

const PROJECT_ID = process.env.FIREBASE_PROJECT_ID;
const SA_JSON = process.env.GOOGLE_APPLICATION_CREDENTIALS_JSON;
const SG_KEY = process.env.SENDGRID_API_KEY;
const WEATHER_KEY = process.env.WEATHER_API_KEY;
const SENDER_EMAIL = process.env.SENDER_EMAIL || "no-reply@yourdomain.com";
const SENDER_NAME = process.env.SENDER_NAME || "Weather Daily";

if (!PROJECT_ID || !SA_JSON || !SG_KEY || !WEATHER_KEY) {
  console.error("Missing env(s): PROJECT_ID/SA_JSON/SENDGRID_API_KEY/WEATHER_API_KEY");
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(JSON.parse(SA_JSON)),
  projectId: PROJECT_ID,
});
const db = admin.firestore();

sgMail.setApiKey(SG_KEY);

// Helpers using fetch (polyfilled above via node-fetch for Node runners / GitHub Actions)

async function getActiveSubscribers() {
  const snap = await db.collection('subscribers')
    .where('confirmed', '==', true)
    .where('unsubscribed', '==', false)
    .get();

  const byCity = {};
  snap.forEach(doc => {
    const d = doc.data();
    if (!d || !d.email || !d.city) return;
    const email = String(d.email).toLowerCase();
    const city = String(d.city);
    if (!byCity[city]) byCity[city] = new Set();
    byCity[city].add(email);
  });

  const out = {};
  for (const [city, set] of Object.entries(byCity)) out[city] = Array.from(set);
  return out;
}

async function getForecast(city) {
  const u = new URL("https://api.weatherapi.com/v1/forecast.json");
  u.searchParams.set("key", WEATHER_KEY);
  u.searchParams.set("q", city);
  u.searchParams.set("days", "1");
  u.searchParams.set("aqi", "no");
  u.searchParams.set("alerts", "no");
  const res = await fetch(u.href);
  if (!res.ok) throw new Error(`WeatherAPI ${res.status}: ${await res.text()}`);
  return res.json();
}

function renderHtml(city, data) {
  const day = data && data.forecast && data.forecast.forecastday && data.forecast.forecastday[0]
    ? data.forecast.forecastday[0].day : {};
  const cond = (day && day.condition) || { text: "N/A", icon: "" };
  let icon = cond.icon || "";
  if (typeof icon === "string" && icon.startsWith("//")) icon = "https:" + icon;

  const val = (v, fb) => (v === undefined || v === null) ? fb : v;
  return `
    <div style="font-family:Arial,sans-serif;color:#333;line-height:1.6">
      <h2 style="color:#5971E8;margin:0 0 12px">🌤 Daily Weather — ${city}</h2>
      <table style="font-size:14px">
        <tr><td style="padding:6px 0">☁️ Condition</td><td style="padding:6px 12px">
          ${icon ? `<img src="${icon}" alt="" style="vertical-align:middle;margin-right:6px" />` : ""}
          <b>${cond.text}</b>
        </td></tr>
        <tr><td style="padding:6px 0">🌡 Temperature</td><td style="padding:6px 12px"><b>${val(day.mintemp_c,"?")}–${val(day.maxtemp_c,"?")}°C</b></td></tr>
        <tr><td style="padding:6px 0">💧 Humidity</td><td style="padding:6px 12px"><b>${val(day.avghumidity,"?")}%</b></td></tr>
        <tr><td style="padding:6px 0">🌬 Wind</td><td style="padding:6px 12px"><b>${val(day.maxwind_kph,"?")} km/h</b></td></tr>
      </table>
      <p style="font-size:12px;color:#777;border-top:1px solid #eee;padding-top:8px">
        You can unsubscribe anytime from our app.
      </p>
    </div>`;
}

function chunk(arr, size) {
  const out = [];
  for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
  return out;
}

(async () => {
  try {
    const byCity = await getActiveSubscribers();
    if (Object.keys(byCity).length === 0) {
      console.log("No active subscribers");
      return;
    }

    for (const [city, emails] of Object.entries(byCity)) {
      try {
        const data = await getForecast(city);
        const html = renderHtml(city, data);
        const batches = chunk(emails, 800); // SendGrid supports many recipients, chia batch cho an toàn

        for (const batch of batches) {
          await sgMail.send({
            to: batch,
            from: { email: SENDER_EMAIL, name: SENDER_NAME },
            subject: `Daily Forecast — ${city}`,
            html
          }, false);
          console.log(`Sent ${batch.length} emails for ${city}`);
        }
      } catch (e) {
        console.error(`Send failed for city ${city}`, e);
      }
    }
  } catch (e) {
    console.error("Job error:", e);
    process.exit(1);
  }
})();
