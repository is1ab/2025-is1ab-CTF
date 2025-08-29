import path from 'path';
import fs from 'fs';

const ID_REGEX = /^[0-9]+$/m;

export default function handler({ query }, res) {
  if (!query.id) {
    res.status(400).end("Missing id parameter");
    return;
  }

  // Check format
  if (!ID_REGEX.test(query.id)) {
    console.error("Invalid format:", query.id);
    res.status(400).end("Invalid format");
    return;
  }
  // Prevent directory traversal
  if (query.id.includes("/") || query.id.includes("..")) {
    console.error("DIRECTORY TRAVERSAL DETECTED:", query.id);
    res.status(400).end("DIRECTORY TRAVERSAL DETECTED?!? This incident will be reported.");
    return;
  }

  try {
    const filepath = path.join("team", query.id + ".png");
    const content = fs.readFileSync(filepath.slice(0, 100));

    res.setHeader("Content-Type", "image/png");
    res.status(200).end(content);
  } catch (e) {
    console.error("Not Found", e.toString());
    res.status(404).end(e.toString());
  }
}
