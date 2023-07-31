import { readdir, readFile, stat } from "node:fs/promises";
import * as path from "path";

export async function hello(name) {
  return `Hello ${name}!`;
}

export async function blogPostsMeta() {
  const dir = path.join("posts");
  const files = await readdir(dir);
  const metadata = await Promise.all(
    files.map((file) => {
      return stat(path.join("posts", file)).then((fileStats) => ({
        stats: {
          ...fileStats,
        },
        file,
      }));
    })
  );

  console.log(metadata);

  return metadata;
}
