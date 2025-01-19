---
title: "Efficient Module Bundling and Smart Imports"
description: "Optimize your Node.js projects with efficient module bundling and smart import structures, enhancing code readability, maintainability, and developer productivity through simplified CommonJS and ECMAScript Module patterns."
author: s-gryt
date: 2024-01-15 15:00:00 CDT
categories:
  - Backend Development
  - Best Practices
  - Coding
  - Coding Practices
  - CommonJS
  - Development
  - ECMAScript Modules
  - JavaScript
  - Node.js
  - Programming Tips
  - Software Engineering
  - Technical Challenges
  - Web Development
tags:
  - Code Efficiency
  - Code Maintainability
  - Code Readability
  - CommonJS (CJS)
  - Dependency Management
  - Development Patterns
  - ECMAScript Modules (ESM)
  - Import Challenges
  - JavaScript Development
  - Module Bundling
  - Node.js Development
  - Performance Optimization
  - Software Architecture
  - Software Design
  - Technical Debt
image:
  path: /assets/img/posts/2024-01-15-import-challenges-in-nodejs/cover.png
  alt: "Import Challenges in Node.js"
---

## Navigating Import Challenges in Node.js Projects

Traditionally, in Node.js projects, a common issue arises where imports consume a significant portion of each file, often comprising one-third or even half of the entire file. The problem stems from the repetitive nature of files, all starting with numerous lines of imports. This redundancy not only clutters the codebase but also imposes unnecessary cognitive load when reading these files. To address this, developers often seek ways to streamline and simplify the import process, improving code readability and maintainability, particularly in the context of `CommonJS (CJS)` and `ECMAScript Modules (ESM)`:

```javascript
"use strict";

const crypto = require("node:crypto");
const fs = require("node:fs");
const http = require("node:http");
const os = require("node:os");
const path = require("node:path");
const timers = require("node:timers");
const util = require("node:util");
const vm = require("node:vm");

const express = require("express");
const joi = require("joi");
const redis = require("redis");
const pg = require("pg");

fs.readFile("./index.js", (err, data) => {
  if (err) console.log({ error: err });
  else console.log({ data });
});
// ...
...
```

```javascript
import crypto from "node:crypto";
import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";
import timers from "node:timers";
import util from "node:util";
import vm from "node:vm";

import * as express from "express";
import * as joi from "joi";
import * as redis from "redis";
import * as pg from "pg";

fs.readFile("./index.mjs", (err, data) => {
  if (err) console.log({ error: err });
  else console.log({ data });
});
// ...
...
```

## Unifying Node Modules and npm Packages in JavaScript

Although modules are singletons in JavaScript, meaning that when we export a module and import it in multiple files, we still reference the same object (let's call it `node`, but you are free to choose any name), combining modules into a unified object can simplify exports.

Let's examine a loader that includes arrays with module names and loops over them to bundle them into a single object. We also add `process` to `node` to simplify its use. Instead of writing `node.fs.promises`, we simplify it to `node.fsp`. Additionally, accessing timers via dot notation like `node.timers.promises` might not work; we have to use `timers/promises`, so we simplify it as well.

This approach streamlines the export of `node` modules and `npm` packages for both CommonJS (`CJS`) and ECMAScript modules (`ESM`) with dynamic imports.

> Certainly, it's important to note that `Object.create(null)` is utilized to create an object without a prototype, resulting in a "pure" dictionary with no inherited properties or methods. This ensures a clean slate for the object.
> Moreover, the exported object is safeguarded against modification or mutation after it's exported through the use of `Object.freeze()`. This step guarantees that the structure and properties of the object remain immutable, providing stability and preventing unintended changes:

```javascript
// modules.js
"use strict";

const node = Object.create(null);
const async = [
  "perf_hooks",
  "async_hooks",
  "timers/promises",
  "timers",
  "events"
];
const multi = ["child_process", "worker_threads"];
const network = ["dns", "net", "tls", "http", "https", "http2", "dgram"];
const streams = ["stream", "fs", "crypto", "zlib", "readline"];
const tools = ["util", "path", "buffer", "os", "v8", "vm"];
const internals = [...async, multi, ...network, ...streams, ...tools];

for (const name of internals) node[name] = require(`node:${name}`);

node.process = process;
node.fsp = node.fs.promises;
node.timers.promises = node["timers/promises"];

module.exports = Object.freeze(node);
```

```javascript
// modules.mjs
const node = Object.create(null);
const async = [
  "perf_hooks",
  "async_hooks",
  "timers/promises",
  "timers",
  "events"
];
const multi = ["child_process", "worker_threads"];
const network = ["dns", "net", "tls", "http", "https", "http2", "dgram"];
const streams = ["stream", "fs", "crypto", "zlib", "readline"];
const tools = ["util", "path", "buffer", "os", "v8", "vm"];

const internals = [...async, multi, ...network, ...streams, ...tools];

for (const name of internals) node[name] = await import(`node:${name}`);

node.process = process;
node.fsp = node.fs.promises;
node.timers.promises = node["timers/promises"];

Object.freeze(node);

export default node;
```

```javascript
// packages.js
"use strict";

const node = require("./modules.js");
const npm = Object.create(null);

const pkgPath = node.path.join(node.process.cwd(), "package.json");
const pkg = require(pkgPath);

if (pkg.dependencies) {
  const modules = Object.keys(pkg.dependencies);
  for (const dep of modules) npm[dep] = require(dep);
}

module.exports = Object.freeze(npm);
```

```javascript
// packages.mjs
import node from "./modules.mjs";

const npm = Object.create(null);
const pkgPath = node.path.join(node.process.cwd(), "package.json");
const pkg = JSON.parse(await node.fsp.readFile(pkgPath));

if (pkg.dependencies) {
  const modules = Object.keys(pkg.dependencies);
  for (const dep of modules) npm[dep] = await import(dep);
}

Object.freeze(npm);

export default npm;
```

## Simplifying Import Structures in CommonJS and ECMAScript Modules

Now, with our organized exports, let's take a look at how imports are structured for both `CommonJS (CJS)` and `ESM (ECMAScript Modules)`:

```javascript
// index.js
"use strict";

const {
  crypto,
  fs,
  http,
  os,
  path,
  timers,
  util,
  vm
} = require("./modules.js");
const { redis, pg } = require("/packages.js");

fs.readFile("./index.js", (err, data) => {
  if (err) console.log({ error: err });
  else console.log({ data });
});

const node = { crypto, fs, http, os, path, timers, util, vm };
const npm = { pg, redis };

console.log({ node, npm });
```

```javascript
// index.mjs
import node from "./modules.mjs";
import npm from "./packages.mjs";

node.fs.readFile("./index.mjs", (err, data) => {
  if (err) console.log({ error: err });
  else console.log({ data });
});

console.log({ node, npm });
```

## Navigating with Ease

Indeed, with the organized structure of `node.<name>` and `npm.<name>`, navigating and locating modules or packages in your codebase becomes much more straightforward. This approach significantly reduces the effort needed to understand and read through the code.

Additionally, for those who value autocompletion in their IDEs, you can enhance the development experience by defining global namespaces in a `global.d.ts` file. This facilitates easier and more efficient coding, as the IDE can provide suggestions and auto-complete code snippets based on the predefined namespaces.

## Conclusion

In conclusion, adopting this streamlined approach not only enhances code readability and developer experience but also seamlessly integrates with tools like `ESLint` to enforce clean and proper import practices. The result is a harmonious synergy that ensures a consistent and maintainable codebase, contributing to the establishment and upkeep of a high-quality code standard. It's a definitive win-win for developers and the overall health of the codebase.
