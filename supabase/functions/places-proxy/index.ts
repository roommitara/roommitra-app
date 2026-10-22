// RoomMitra: Google Places/Geocoding ka surakshit darwaza. Chabi (GOOGLE_PLACES_KEY) sirf yahin rehti hai.
// Sirf login kiya hua user chala sakta hai (verify_jwt = true).
import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};
const json = (b: unknown, s = 200) =>
  new Response(JSON.stringify(b), { status: s, headers: { ...cors, "Content-Type": "application/json" } });

const KEY = Deno.env.get("GOOGLE_PLACES_KEY") ?? "";
const CENTERS: Record<string, [number, number]> = {
  "Nahan": [30.5593, 77.2959],
  "Paonta Sahib": [30.4367, 77.6240],
  "Solan": [30.9045, 77.0967],
  "Shimla": [31.1048, 77.1734],
};

function km(a: [number, number], b: [number, number]) {
  const dLat = (a[0] - b[0]) * 111;
  const dLng = (a[1] - b[1]) * 111 * Math.cos(a[0] * Math.PI / 180);
  return Math.sqrt(dLat * dLat + dLng * dLng);
}

async function places(path: string, body: unknown, mask: string) {
  const r = await fetch(`https://places.googleapis.com/v1/${path}`, {
    method: "POST",
    headers: { "Content-Type": "application/json", "X-Goog-Api-Key": KEY, "X-Goog-FieldMask": mask },
    body: JSON.stringify(body),
  });
  return await r.json();
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  try {
    if (!KEY) return json({ error: "GOOGLE_PLACES_KEY secret missing" }, 500);
    const b = await req.json();
    const action = String(b.action ?? "");

    if (action === "autocomplete") {
      const q = String(b.q ?? "").slice(0, 100);
      if (q.length < 2) return json({ items: [] });
      const center = CENTERS[String(b.city ?? "")] ?? CENTERS["Nahan"];
      const j = await places("places:autocomplete", {
        input: q,
        sessionToken: b.session ? String(b.session) : undefined,
        includedRegionCode: "in",
        languageCode: "en",
        locationBias: { circle: { center: { latitude: center[0], longitude: center[1] }, radius: 50000 } },
      }, "*");
      const items = (j.suggestions ?? [])
        .filter((s: any) => s.placePrediction)
        .map((s: any) => ({ id: s.placePrediction.placeId, text: s.placePrediction.text?.text ?? "" }));
      return json({ items });
    }

    if (action === "details") {
      const id = String(b.id ?? "").replace(/[^A-Za-z0-9_-]/g, "");
      const sess = b.session ? `?sessionToken=${encodeURIComponent(String(b.session))}` : "";
      const r = await fetch(`https://places.googleapis.com/v1/places/${id}${sess}`, {
        headers: { "X-Goog-Api-Key": KEY, "X-Goog-FieldMask": "location,formattedAddress,displayName" },
      });
      const j = await r.json();
      if (!j.location) return json({ error: "not found" }, 404);
      return json({
        lat: j.location.latitude, lng: j.location.longitude,
        address: j.formattedAddress ?? "", name: j.displayName?.text ?? "",
      });
    }

    if (action === "reverse") {
      const lat = Number(b.lat), lng = Number(b.lng);
      if (!isFinite(lat) || !isFinite(lng)) return json({ error: "bad coords" }, 400);
      const r = await fetch(
        `https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat},${lng}&language=en&key=${KEY}`);
      const j = await r.json();
      const results: any[] = j.results ?? [];
      if (!results.length) return json({ address: "", city: "", locality: "" });
      const find = (types: string[]) => {
        for (const res of results) {
          for (const c of res.address_components ?? []) {
            if (types.some((t) => c.types.includes(t))) return String(c.long_name);
          }
        }
        return "";
      };
      return json({
        address: results[0].formatted_address ?? "",
        city: find(["locality", "administrative_area_level_3"]),
        locality: find(["sublocality_level_1", "sublocality", "neighborhood"]),
      });
    }

    if (action === "areas") {
      const city = String(b.city ?? "");
      const center = CENTERS[city];
      if (!center) return json({ error: "unknown city" }, 400);
      const db = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
      const { count } = await db.from("city_areas").select("name", { count: "exact", head: true }).eq("city", city);
      if ((count ?? 0) > 0) return json({ cached: true });

      const queries: [string, boolean][] = [
        [`neighbourhoods in ${city}`, true], [`colonies in ${city}`, true],
        [`localities areas in ${city}`, true], [`sectors in ${city}`, true],
        [`chowk in ${city}`, false], [`market in ${city}`, false],
        [`${city} bus stand railway station`, false], [`temple lake park in ${city}`, false],
      ];
      const seen = new Map<string, { city: string; name: string; lat: number; lng: number }>();
      const okTypes = ["sublocality", "sublocality_level_1", "sublocality_level_2", "neighborhood", "political"];
      await Promise.all(queries.map(async ([q, strict]) => {
        const j = await places("places:searchText", {
          textQuery: q, languageCode: "en", pageSize: 20,
          locationBias: { circle: { center: { latitude: center[0], longitude: center[1] }, radius: 12000 } },
        }, "places.displayName,places.location,places.types");
        for (const p of j.places ?? []) {
          const name = String(p.displayName?.text ?? "").trim();
          if (!name || !p.location) continue;
          if (name.toLowerCase() === city.toLowerCase()) continue;
          if (km(center, [p.location.latitude, p.location.longitude]) > 14) continue;
          const types: string[] = p.types ?? [];
          if (strict && !types.some((t) => okTypes.includes(t))) continue;
          const k = name.toLowerCase();
          if (!seen.has(k)) seen.set(k, { city, name, lat: p.location.latitude, lng: p.location.longitude });
        }
      }));
      const rows = [...seen.values()];
      if (rows.length) await db.from("city_areas").upsert(rows, { onConflict: "city,name" });
      return json({ cached: false, count: rows.length });
    }

    return json({ error: "unknown action" }, 400);
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
