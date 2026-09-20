import fs from 'node:fs/promises';
import {Workbook,SpreadsheetFile} from '@oai/artifact-tool';
const out='D:/mv/outputs/employee-pay-01a0b1e1';
const w=Workbook.create();
const f=w.worksheets.add('Employee Form'), r=w.worksheets.add('Payment Register');
const navy='#123C60', amber='#FFF2CC', gray='#EAF0F5';
const logo='data:image/png;base64,'+(await fs.readFile('D:/mv/assets/logo/MV-Manufacturing.png')).toString('base64');
function val(s,a,v){s.getRange(a).values=[[v]];} function fx(s,a,v){s.getRange(a).formulas=[[v]];}
function merge(s,a,v){s.mergeCells(a);val(s,a.split(':')[0],v);}
function input(s,a){s.getRange(a).format.fill=amber;}
function band(s,a){s.getRange(a).format.fill=navy;s.getRange(a).format.font.color='#FFFFFF';s.getRange(a).format.font.bold=true;}
function base(s,end){s.showGridLines=false;s.getRange('A1:'+end).format.font={name:'Arial',size:10,color:'#233342'};s.getRange('A1:'+end).format.rowHeight=23;s.getRange('A1:'+end).format.verticalAlignment='center';s.images.add({dataUrl:logo,anchor:{from:{row:1,col:0},extent:{widthPx:145,heightPx:87}}});s.tabColor=navy;}
base(f,'H51');f.getRange('A1:H51').format.columnWidth=14;f.getRange('A1:A51').format.columnWidth=16;f.getRange('G1:H51').format.columnWidth=19;
merge(f,'C2:H2','MV MANUFACTURING LLC');f.getRange('C2').format.font={size:16,bold:true,color:navy};merge(f,'C3:H3','BIWEEKLY EMPLOYEE PAYMENT FORM');merge(f,'C4:H4','545 Aldo Ave, Ste 10 • Santa Clara, CA 95054');
merge(f,'A6:H6','Yellow cells = enter information  |  Blue-gray cells = automatic totals  |  USD');
val(f,'A8','Employee name');merge(f,'B8:D8','');input(f,'B8:D8');val(f,'E8','Employee ID');merge(f,'F8:H8','');input(f,'F8:H8');
val(f,'A9','Period start');input(f,'B9');val(f,'C9','Period end');fx(f,'D9','=IF(B9="","",B9+13)');val(f,'E9','Pay date');input(f,'F9');val(f,'G9','Department / job');input(f,'H9');
val(f,'A10','Hourly rate');input(f,'B10');val(f,'C10','OT rate (1.5×)');fx(f,'D10','=IF(B10="","",B10*1.5)');val(f,'E10','DT rate (2×)');fx(f,'F10','=IF(B10="","",B10*2)');val(f,'G10','Workweek begins');input(f,'H10');
merge(f,'A12:H12','Enter approved hours in decimal form (7.5 = 7h 30m). Exclude unpaid breaks.');
f.getRange('A13:H13').values=[['Date','Day','Regular hrs','OT hrs (1.5×)','DT hrs (2×)','Total hrs','Work / job notes','']];f.mergeCells('G13:H13');band(f,'A13:H13');f.getRange('A13:H13').format.rowHeight=28;
for(let i=0;i<14;i++){let n=14+i;fx(f,`A${n}`,`=IF($B$9="","",$B$9+${i})`);fx(f,`B${n}`,`=IF(A${n}="","",TEXT(A${n},"ddd"))`);input(f,`C${n}:E${n}`);fx(f,`F${n}`,`=IF(COUNT(C${n}:E${n})=0,"",SUM(C${n}:E${n}))`);f.mergeCells(`G${n}:H${n}`);input(f,`G${n}:H${n}`);f.getRange(`F${n}`).format.fill=gray;}
f.getRange('A21:H21').format.borders={top:{style:'medium',color:navy}};
merge(f,'A28:B28','TOTAL');for(const c of ['C','D','E','F'])fx(f,`${c}28`,`=IF(COUNT(C14:E27)=0,"",SUM(${c}14:${c}27))`);band(f,'A28:H28');
val(f,'A30','Days worked');fx(f,'B30','=IF(COUNT(C14:E27)=0,"",COUNTIF(F14:F27,">0"))');val(f,'C30','Regular pay');fx(f,'D30','=IF(OR(B10="",C28=""),"",ROUND(C28*B10,2))');val(f,'E30','Overtime pay');fx(f,'F30','=IF(OR(B10="",D28=""),"",ROUND(D28*D10,2))');val(f,'G30','Double-time pay');fx(f,'H30','=IF(OR(B10="",E28=""),"",ROUND(E28*F10,2))');
merge(f,'A32:C32','Other approved earnings ($)');input(f,'D32');merge(f,'E32:H32','Include payroll-reviewed premiums / paid leave.');
merge(f,'A33:C33','GROSS PAY');fx(f,'D33','=IF(D30="","",SUM(D30,F30,H30,D32))');
merge(f,'A34:C34','Taxes + deductions ($)');input(f,'D34');merge(f,'E34:H34','Enter payroll total; enter 0 if none.');
merge(f,'A35:C35','Expense reimbursements ($)');input(f,'D35');merge(f,'E35:H35','Reimbursements are separate from earnings.');
merge(f,'A36:C36','NET PAYMENT');fx(f,'D36','=IF(OR(D33="",D34=""),"",ROUND(D33-D34+N(D35),2))');band(f,'A36:D36');
val(f,'E37','Amount paid');input(f,'F37');val(f,'G37','Balance due');fx(f,'H37','=IF(D36="","",ROUND(D36-N(F37),2))');
val(f,'A38','Method');merge(f,'B38:D38','');input(f,'B38:D38');val(f,'E38','Paid on');input(f,'F38');val(f,'G38','Reference #');input(f,'H38');f.getRange('B38').dataValidation={rule:{type:'list',values:['Direct deposit','Check','Cash','Other']}};
merge(f,'A40:B40','Employee signature');merge(f,'C40:D40','');input(f,'C40:D40');merge(f,'E40:F40','Approved by / date');merge(f,'G40:H40','');input(f,'G40:H40');
merge(f,'A42:H42','HOW TO USE');band(f,'A42:H42');
const notes=[
'1. Save a copy for each employee and pay period. Enter dates, rate, and approved daily hours.',
'2. Regular / OT / DT hours are entered manually; this form does not classify overtime automatically.',
'3. California generally requires daily, weekly and seventh-day overtime; see the official source below.',
'4. Use payroll-reviewed rates / earnings for bonuses, multiple rates or special schedules. Taxes are manual.',
'5. Record the finalized payment as values in Payment Register. The register does not auto-link this form.',
'Internal payment record, not a substitute for an itemized wage statement or underlying time records.',
'CA overtime: https://www.dir.ca.gov/dlse/faq_overtime.htm',
'Payroll records: https://www.dol.gov/agencies/whd/fact-sheets/21-flsa-recordkeeping'];
notes.forEach((n,i)=>merge(f,`A${43+i}:H${43+i}`,n));f.getRange('A43:H50').format.font.size=9;
for(const a of ['B9','D9','F9','F38','A14:A27'])f.getRange(a).setNumberFormat('mmm d, yyyy');for(const a of ['B10','D10','F10','D30','F30','H30','D32:D36','F37','H37'])f.getRange(a).setNumberFormat('$#,##0.00;[Red]($#,##0.00)');f.getRange('C14:F28').setNumberFormat('0.00');
f.dataValidations.add({range:'C14:E27',rule:{type:'decimal',operator:'between',formula1:0,formula2:24}});
f.getRange('F14:F27').conditionalFormats.add('cellIs',{operator:'greaterThan',formula:24,format:{fill:'#FFDAD6'}});
base(r,'N110');r.getRange('A1:N110').format.columnWidth=16;r.getRange('A1:A110').format.columnWidth=24;r.getRange('N1:N110').format.columnWidth=22;
merge(r,'C2:H2','MV MANUFACTURING LLC');r.getRange('C2').format.font={size:16,bold:true,color:navy};merge(r,'C3:H3','EMPLOYEE PAYMENT REGISTER');
merge(r,'A6:N6','One row per employee per pay period. Enter finalized values from the Employee Form or payroll records.');
val(r,'A8','Total net payment');fx(r,'B8','=SUM(G12:G111)');val(r,'D8','Total paid');fx(r,'E8','=SUM(H12:H111)');val(r,'G8','Balance due');fx(r,'H8','=SUM(I12:I111)');
merge(r,'A9:N9','Enter 0 for deductions / reimbursements / paid amount when none. Status reflects amounts and payment details, not payroll approval.');
r.getRange('A11:N11').values=[['Employee name','Period start','Period end','Gross pay','Taxes / deductions','Reimbursements','Net payment','Amount paid','Balance due','Status','Paid on','Method','Reference #','Notes / employee ID']];band(r,'A11:N11');r.getRange('A11:N11').format.wrapText=true;r.getRange('A11:N11').format.rowHeight=32;
for(let n=12;n<=111;n++){input(r,`A${n}:B${n}`);input(r,`D${n}:F${n}`);input(r,`H${n}`);input(r,`K${n}:N${n}`);fx(r,`C${n}`,`=IF(B${n}="","",B${n}+13)`);fx(r,`G${n}`,`=IF(OR(A${n}="",D${n}="",E${n}="",F${n}=""),"",ROUND(D${n}-E${n}+F${n},2))`);fx(r,`I${n}`,`=IF(OR(G${n}="",H${n}=""),"",ROUND(G${n}-H${n},2))`);fx(r,`J${n}`,`=IF(A${n}="","",IF(OR(B${n}="",G${n}="",H${n}=""),"Incomplete",IF(I${n}<0,"Overpaid",IF(I${n}>0,IF(H${n}=0,"Unpaid","Partial"),IF(OR(K${n}="",L${n}=""),"Add paid details","Paid")))))`);}
r.getRange('L12:L111').dataValidation={rule:{type:'list',values:['Direct deposit','Check','Cash','Other']}};
for(const a of ['B12:C111','K12:K111'])r.getRange(a).setNumberFormat('mmm d, yyyy');for(const a of ['D12:I111','B8','E8','H8'])r.getRange(a).setNumberFormat('$#,##0.00;[Red]($#,##0.00)');
r.getRange('J12:J111').conditionalFormats.add('containsText',{text:'Unpaid',format:{fill:'#FFDAD6'}});r.getRange('J12:J111').conditionalFormats.add('containsText',{text:'Partial',format:{fill:amber}});r.freezePanes.freezeRows(11);r.tables.add('A11:N111',true,'PaymentRegister');
// Exercise pay arithmetic and input-driven payment states, then restore blank template.
val(f,'B10',20);val(f,'C14',8);val(f,'D14',2);val(f,'E14',1);val(f,'D34',30);val(f,'D35',10);w.recalculate();
if(f.getRange('D36').values[0][0]!==240)throw Error('Net pay test failed '+JSON.stringify(f.getRange('D36').values));
val(r,'A12','Test');val(r,'B12',46000);val(r,'D12',260);val(r,'E12',30);val(r,'F12',10);val(r,'H12',100);w.recalculate();if(r.getRange('I12').values[0][0]!==140||r.getRange('J12').values[0][0]!=='Partial')throw Error('Register test failed');
for(const a of ['B10','C14:E14','D34:D35'])f.getRange(a).clear({applyTo:'contents'});for(const a of ['A12:B12','D12:F12','H12'])r.getRange(a).clear({applyTo:'contents'});w.recalculate();
console.log((await w.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!',options:{useRegex:true,maxResults:20},summary:'Formula error scan'})).ndjson);
for(const [s,range,name] of [[f,'A1:H50','form'],[r,'A1:N16','register']]){const p=await w.render({sheetName:s.name,range,scale:1.5,format:'png'});await fs.writeFile(`${out}/${name}.png`,new Uint8Array(await p.arrayBuffer()));}
await(await SpreadsheetFile.exportXlsx(w)).save(`${out}/MV_Manufacturing_Biweekly_Payroll.xlsx`);
console.log('Exported; arithmetic and partial-payment tests passed.');
