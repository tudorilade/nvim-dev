// Practice file for nvim-dev drills (JavaScript).
// Lots of repetition and quotes/brackets to practice surround, multi-cursor,
// text objects, and exchange. See docs/10-practice-drills.md.

// Drill 6: change the single quotes to double quotes with cs'"
const greeting = 'hello world';

// Drill 7: with the cursor inside the array, try di[  yi[  ci[
const colors = ['red', 'green', 'blue', 'yellow'];

// Drill 8: swap the two arguments using vim-exchange (cxiw ... cxiw)
function makePair(first, second) {
  return { first: first, second: second };
}

// Drill 19: multi-cursor — change every `item` to `entry` with <C-n>
function process(items) {
  const result = [];
  for (const item of items) {
    const item_value = item.value;
    result.push(item_value);
  }
  return result;
}

// Repetitive object — great for macros / multi-cursor
const users = [
  { name: 'alice', role: 'admin' },
  { name: 'bob', role: 'user' },
  { name: 'carol', role: 'user' },
];

// Drill 5: delete this whole block with dap (delete a paragraph)
const TEMP_DEBUG = true;
const TEMP_VERBOSE = true;
const TEMP_TRACE = true;

// Badly formatted line: fix with <leader>cf (prettier)
const config = { enabled: true, retries: 3, timeout: 1000, name: "client" }

console.log(greeting);
console.log(colors);
console.log(makePair(1, 2));
console.log(process(users));
console.log(config);
