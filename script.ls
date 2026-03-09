let budget=Number(localStorage.getItem("budget"))||0
let expenses=JSON.parse(localStorage.getItem("expenses"))||[]
let chart

function saveData(){
localStorage.setItem("budget",budget)
localStorage.setItem("expenses",JSON.stringify(expenses))
}

function calculateTotal(){
let total=0
expenses.forEach(e=>{total+=Number(e.amount)})
return total
}

function updateDashboard(){

let total=calculateTotal()
let remaining=budget-total

document.getElementById("budget").innerText="₹"+budget
document.getElementById("spent").innerText="₹"+total
document.getElementById("remaining").innerText="₹"+remaining
document.getElementById("transactions").innerText=expenses.length

generateAIInsights()
}

function setBudget(){

let value=Number(document.getElementById("budgetInput").value)

if(value<=0){
alert("Enter valid budget")
return
}

budget=value
saveData()
updateDashboard()

}

function addExpense(){

let date=document.getElementById("date").value
let name=document.getElementById("name").value
let category=document.getElementById("category").value
let amount=Number(document.getElementById("amount").value)

if(name==""||amount<=0){
alert("Enter valid expense")
return
}

expenses.push({date,name,category,amount})

saveData()

renderTable()
updateDashboard()
updateChart()

}

function deleteExpense(index){

expenses.splice(index,1)

saveData()

renderTable()
updateDashboard()
updateChart()

}

function clearAll(){

let confirmDelete=confirm("Are you sure you want to delete all expenses?")

if(confirmDelete){

expenses=[]
budget=0

localStorage.removeItem("expenses")
localStorage.removeItem("budget")

renderTable()
updateDashboard()
updateChart()

document.getElementById("aiInsight").innerHTML="📊 All data cleared."

}

}

function renderTable(){

let html=""

expenses.forEach((e,i)=>{

html+=`
<tr>
<td>${e.date}</td>
<td>${e.name}</td>
<td>${e.category}</td>
<td>₹ ${e.amount}</td>
<td><button class="delete-btn" onclick="deleteExpense(${i})">Delete</button></td>
</tr>
`

})

document.getElementById("table").innerHTML=html

}

function updateChart(){

let categoryTotals={}

expenses.forEach(e=>{
if(categoryTotals[e.category])
categoryTotals[e.category]+=e.amount
else
categoryTotals[e.category]=e.amount
})

let labels=Object.keys(categoryTotals)
let data=Object.values(categoryTotals)

if(chart) chart.destroy()

chart=new Chart(document.getElementById("chart"),{
type:"pie",
data:{
labels:labels,
datasets:[{data:data}]
}
})

}

function searchExpense(){

let input=document.getElementById("search").value.toLowerCase()
let rows=document.querySelectorAll("#table tr")

rows.forEach(row=>{
let text=row.innerText.toLowerCase()
row.style.display=text.includes(input)?"":"none"
})

}

function downloadPDF(){

const { jsPDF } = window.jspdf
let doc=new jsPDF()

doc.text("Expense Report",20,20)

let y=40

expenses.forEach(e=>{
doc.text(`${e.date} | ${e.name} | ${e.category} | ₹${e.amount}`,20,y)
y+=10
})

doc.save("Expense_Report.pdf")

}

function shareReport(){

let text="My Expense Report\n"

expenses.forEach(e=>{
text+=`${e.name} - ₹${e.amount}\n`
})

if(navigator.share){
navigator.share({
title:"Expense Report",
text:text
})
}else{
alert("Sharing not supported")
}

}

function generateAIInsights(){

if(expenses.length==0){
document.getElementById("aiInsight").innerHTML=
"📊 Start adding expenses to receive financial insights."
return
}

let total=calculateTotal()
let percent=(total/budget)*100
let remaining=budget-total

let message=""

if(percent>=100)
message="🚨 Budget exceeded!"

else if(percent>80)
message="⚠️ You already spent "+Math.round(percent)+"% of your budget."

else if(percent>50)
message="📊 Moderate spending."

else
message="✅ Excellent spending control."

message+="<br>💰 Remaining Budget: ₹"+remaining

document.getElementById("aiInsight").innerHTML=message

}

renderTable()
updateDashboard()
updateChart()