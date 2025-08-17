const sgMail = require("@sendgrid/mail");
const crypto = require("crypto");

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

sgMail.setApiKey(SG_KEY);

// Minimal helpers using Node18 global fetch
async function getAccessTokenFromSA(saJson, scope) {
  const sa = JSON.parse(saJson);
  const header = base64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const now = Math.floor(Date.now() / 1000);
  const claim = base64url(JSON.stringify({
    iss: sa.client_email,
    sub: sa.client_email,
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
    scope
  }));
  const toSign = `${header}.${claim}`;
  const signature = signRS256(toSign, sa.private_key);
  const assertion = `${toSign}.${signature}`;

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion
    })
  });
  if (!res.ok) throw new Error(`Token error ${res.status}: ${await res.text()}`);
  const j = await res.json();
  return j.access_token;
}

function base64url(b64str) {
  return Buffer.from(b64str).toString("base64")
    .replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
}
function signRS256(data, privKey) {
  const sign = crypto.createSign("RSA-SHA256");
  sign.update(data);
  sign.end();
  return sign.sign(privKey, "base64").replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
}

async function runQuery(accessToken, body) {
  const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents:runQuery`;
  const r = await fetch(url, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${accessToken}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify(body)
  });
  if (!r.ok) throw new Error(`runQuery ${r.status}: ${await r.text()}`);
  return r.json();
}

async function getActiveSubscribers(accessToken) {
  const q = {
    structuredQuery: {
      from: [{ collectionId: "subscribers" }],
      where: {
        compositeFilter: {
          op: "AND",
          filters: [
            { fieldFilter: { field: { fieldPath: "confirmed" }, op: "EQUAL", value: { booleanValue: true } } },
            { fieldFilter: { field: { fieldPath: "unsubscribed" }, op: "EQUAL", value: { booleanValue: false } } }
          ]
        }
      }
    }
  };
  const rows = await runQuery(accessToken, q);
  const byCity = {};
  for (const r of rows) {
    const doc = r.document;
    if (!doc || !doc.fields) continue;
    const email = (doc.fields.email && doc.fields.email.stringValue) || "";
    const city = (doc.fields.city && doc.fields.city.stringValue) || "";
    if (!email || !city) continue;
    if (!byCity[city]) byCity[city] = new Set();
    byCity[city].add(email.toLowerCase());
  }
  // convert Set -> array
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
    const token = await getAccessTokenFromSA(SA_JSON, "https://www.googleapis.com/auth/datastore");
    const byCity = await getActiveSubscribers(token);
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
