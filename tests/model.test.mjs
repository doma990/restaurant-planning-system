import test from 'node:test';
import assert from 'node:assert/strict';
import * as m from '../demo/model.mjs';
test('delivery dates match the Haskell brief, including recipe expansion',()=>{
 assert.deepEqual(m.calculateDeliveryDates('2026-02-10',['rice','apples','dough','apples']),[
 {date:'2026-01-21',name:'rice',price:1.2},{date:'2026-02-05',name:'apples',price:5},
 {date:'2026-02-09',name:'flour',price:.5},{date:'2026-02-09',name:'eggs',price:2},{date:'2026-02-05',name:'apples',price:5}]);
});
test('delivery summaries combine duplicates and sort dates and names',()=>{
 assert.deepEqual(m.summarizeAllDeliveries(m.parseShopping(m.defaultShopping)).filter(x=>x.date==='2026-02-16'),[
 {date:'2026-02-16',name:'eggs',price:2,quantity:1,total:2},{date:'2026-02-16',name:'flour',price:.5,quantity:3,total:1.5}]);
});
test('year boundaries and leap days are handled',()=>{
 assert.equal(m.calculateDeliveryDates('2026-01-10',['rice'])[0].date,'2025-12-21');
 assert.equal(m.calculateDeliveryDates('2024-03-01',['apples'])[0].date,'2024-02-25');
});
test('nested recipes flatten without losing repeated ingredients',()=>assert.deepEqual(m.flattenIngredients(['pastry','flour']),['flour','eggs','butter','flour']));
test('popularity handles ties, repeated entries, and no orders',()=>{
 assert.deepEqual(m.mostPopularDish(['rice','soup','cake','rice']),['rice']);
 assert.deepEqual(m.mostPopularDish(['rice','cake','rice','cake']).sort(),['cake','rice']);
 assert.deepEqual(m.mostPopularDish([]),[]);
});
test('expense totals and nested category counts match the course example',()=>{
 const tree={name:'Restaurant Expenses',children:[{name:'Food Supplies',children:[{name:'Vegetables',price:450.5},{name:'Meat',price:890}]},{name:'Salaries',children:[{name:'Kitchen',children:[{name:'Chef',price:3500}]},{name:'Service',children:[{name:'Waiter',price:2000}]}]}]};
 assert.equal(m.calculateTotalExpenses(tree),6840.5);assert.equal(m.countCategoryItems('Salaries',tree),2);assert.equal(m.countCategoryItems('Missing',tree),0);
});
test('supplies become one expense item per dated supply',()=>{
 const d=m.summarizeAllDeliveries([{date:'2026-02-17',items:['flour','flour']}]);
 assert.equal(m.countCategoryItems('Food Supplies',m.getDeliveryExpenses(d)),1);assert.equal(m.calculateTotalExpenses(m.getDeliveryExpenses(d)),1);
});
test('extra expense categories preserve nesting and counts',()=>{
 const tree=m.expenseTree([],'Salaries / Service | Waiter | 2000 | 2026-02-01\nSalaries / Kitchen | Chef | 3500 | 2026-02-01');
 assert.equal(m.calculateTotalExpenses(tree),5500);assert.equal(m.countCategoryItems('Salaries',tree),2);
});
test('invalid dates, unknown ingredients, and duplicate dates are rejected',()=>{
 assert.throws(()=>m.parseShopping('2026-02-30 | rice'));
 assert.throws(()=>m.parseShopping('2026-02-15 | rice\n2026-02-15 | flour'));
 assert.throws(()=>m.calculateDeliveryDates('2026-02-15',['unknown']));
});
test('reservation inputs reject duplicate groups and Prolog syntax',()=>{
 const c=m.defaultConfig();c.groups[0].name="a). halt. %";assert.throws(()=>m.validateConfig(c));
 const d=m.defaultConfig();d.groups[1].name=d.groups[0].name;assert.throws(()=>m.validateConfig(d));
});
test('reservation dates respect the yearless Prolog representation',()=>{
 const c=m.defaultConfig();c.days[0].date='2027-02-15';assert.throws(()=>m.validateConfig(c));
});
test('negative, fractional, and blank numbers are rejected',()=>{
 for(const value of [-1,1.5,''])assert.throws(()=>m.integer(value,0,90,'Value'));
 assert.throws(()=>m.validateCatalog([['rice',20,'']]));
});
test('CSV correctly escapes commas and quotes',()=>assert.equal(m.csv(['Name'],[['a,"b"']]),'Name\n"a,""b"""\n'));
