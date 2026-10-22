# Restaurant Planning System

**Prolog · Haskell · Logic programming · Functional programming**

A two-milestone team project for **CSEN 403: Concepts of Programming Languages**, German University in Cairo, Spring 2026. The original submissions are preserved as [`prolog/48.pl`](prolog/48.pl) and [`haskell/48.hs`](haskell/48.hs).

[Try the interactive demo](https://doma990.github.io/projects/restaurant-planner/demo/) · [Design walkthrough](https://doma990.github.io/projects/restaurant-planner/)

## 1. Prolog: reservations and ingredients

The first milestone models restaurant facts as a knowledge base: groups, staff, tables, recipes, and orders. The scheduler uses unification, recursion, and backtracking to find reservations satisfying four conditions:

- A table can seat the whole group.
- A group is seated at its preferred time, morning or evening.
- A table is not double booked on the same date and time.
- Occupied tables do not outnumber the available staff at either time slot.

The ingredient predicates expand ordered dishes into ingredients, preserve repeated ingredients, and group requirements by date. Two CSV writers export the reservation schedule and daily shopping list.

Key predicates: `check_staff/3`, `schedule_all_reservations/2`, `group_ingredients/2`, `needed_ingredients/2`, `write_reservations_to_csv/2`, and `write_ingredients_to_csv/2`.

## 2. Haskell: supplies and expenses

The second milestone uses recursive algebraic data types:

```haskell
data Ingredient = SimpleIngredient String | Recipe String [Ingredient]
data Expense = Item String Price Date | Category String [Expense]
```

The implementation flattens nested recipes, subtracts ingredient lead times from required dates, combines repeated supplies, and sorts the plan by date and ingredient name. It converts deliveries to expense items, finds the most frequently ordered dishes, sums an expense tree, and counts items beneath a named category.

The code demonstrates pattern matching, recursion, list comprehensions, `map`, `filter`, and folds. The supplied `ingredient_info` and `shopping_list` are the original course example data.

Key functions: `calculateDeliveryDates`, `summarizeAllDeliveries`, `getDeliveryExpenses`, `mostPopularDish`, `calculateTotalExpenses`, and `countCategoryItems`.

## Interactive portfolio demo

The [`demo/`](demo/) folder adds a web interface around the project:

| Tab | What runs |
| --- | --- |
| Reservations / Prolog | The unchanged `48.pl`, executed by SWI-Prolog WebAssembly in a worker. |
| Supplies & expenses / Haskell | An explicitly labelled JavaScript adaptation of the submitted Haskell functions. It does not execute `48.hs` in the browser. |

Edit groups, table capacities, dates, staffing, and dish orders. Generate a schedule, download the original Prolog CSV output, then choose **Plan these supplies** to transfer its ingredient list to the second tab. There, adjust supplier lead times and prices, inspect order dates and expenses, and export a supply plan.

The browser handoff and interface are new portfolio additions. The original milestones were separate: the Prolog code exports CSV, while the Haskell submission reads data defined in its source. The demo menu is illustrative and uses ingredients from the Haskell starter data; it is not the original course knowledge base.

The Prolog date type stores only day and month, so the reservation demo fixes the year to 2026. It shows one valid solution and bounds the search to keep the page responsive. The Haskell adaptation accepts dates from 2020 to 2035, validates form input, and uses JavaScript numbers rather than Haskell `Float`; displayed costs are rounded to two decimals. “Order by” is the needed date minus the supplier lead time.

The first Prolog run downloads the pinned `swipl-wasm` 8.1.4 engine from jsDelivr. No account or server is required. To preview the demo locally, serve the repository over HTTP, for example:

```sh
python -m http.server 8000
```

Then open `http://localhost:8000/demo/`.

## Run the original submissions

### Prolog

Install [SWI-Prolog](https://www.swi-prolog.org/Download.html), open a terminal in `prolog/`, and start it with:

```sh
swipl 48.pl sample_KB.pl
```

Try:

```prolog
schedule_all_reservations([day(15,2),day(17,2)], Schedule).
group_ingredients(b, Ingredients).
```

Load one knowledge base at a time. `public_kb.pl` is a larger example.

### Haskell

Install [GHC / GHCi](https://www.haskell.org/ghcup/), open a terminal in `haskell/`, and load:

```sh
ghci 48.hs
```

Try:

```haskell
summarizeAllDeliveries [(15,Feb,2026),(17,Feb,2026)]
mostPopularDish ["rice","soup","cake","rice"]
```

These are collections of predicates and functions, so they are used through their language interpreters rather than a standalone executable.

## Verification

Automated checks cover browser supply calculations, nested expenses, date boundaries, invalid input, the actual Prolog scheduler and CSV writers, and reference examples evaluated against the original Haskell submission. The provided course test spreadsheets are retained in `tests/` as additional references; they are not claimed as a fully automated or fully passing grading suite.

For the JavaScript and Prolog checks, with Node.js installed:

```sh
npm ci
npm test
```

With GHC and Python installed, run `python tests/check-haskell.py` to evaluate the original Haskell reference checks. The GitHub Actions workflow runs both groups.

## Credits and provenance

The coursework was completed as a team project. Course descriptions, starter types, example knowledge bases, and supplied test cases are credited to the **German University in Cairo**, **Dr. Yomna Hassan**, and **Dr. Mary Guindy**. The original source files have been imported without rewriting their implementation or fabricating earlier Git history.

- [Prolog milestone brief](docs/prolog-brief.pdf)
- [Haskell milestone brief](docs/haskell-brief.pdf)
- Browser runtime: [SWI-Prolog WebAssembly](https://github.com/SWI-Prolog/npm-swipl-wasm), version 8.1.4. See [third-party notices](THIRD_PARTY_NOTICES.md).

The Haskell brief labels the course Spring 2026 but contains a 2025 due-date line; the project is documented as Spring 2026 based on the course heading and submission context.
