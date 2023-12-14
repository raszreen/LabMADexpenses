import 'package:flutter/material.dart';
import 'Controller/request_controller.dart';
import 'Model/expense.dart';

class DailyExpensesApp extends StatelessWidget {

  // Constructor parameter to accept the Username value
  final String username;
  const DailyExpensesApp({required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // username will be passed to ExpenseList()
      home: ExpenseList(username: username),
    );
  }
}

class ExpenseList extends StatefulWidget {

  // Constructor parameter to accept the Username value
  final String username;
  ExpenseList({required this.username});

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {

  final List<Expense> expenses = [];
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController txtDateController = TextEditingController();
  double totalAmount = 0.0;
  // added new parameter for Expense Constructor = DateTime text

  void _addExpense() async{
    String description = descriptionController.text.trim();
    String amount = amountController.text.trim();
    int id = 0;

    if(description.isNotEmpty && amount.isNotEmpty){
      Expense exp
      = Expense(0, double.parse(amount) as double, description, txtDateController.text);

      if(await exp.save()){
        setState(() {
          expenses.add(exp);
          descriptionController.clear();
          amountController.clear();
          calculateTotal();
        });
      }else{
        _showMessage("Failed to save Expenses data");
      }
    }
  }

  void calculateTotal(){
    totalAmount = 0;
    for(Expense ex in expenses) {
      totalAmount += ex.amount;
    }
    totalController.text = totalAmount.toString();
  }

  void _removeExpense(int index){
    totalAmount = totalAmount - expenses[index].amount;
    Expense exp = Expense(expenses[index].id as int?, expenses[index].amount as double,
        expenses[index].desc, expenses[index].dateTime);

    exp.delete();
    setState(() {
      expenses.removeAt(index);
      totalController.text = totalAmount.toString();
    });
  }

  void _showMessage(String msg){
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg)
        ),
      );
    }
  }

  void _editExpense(int index)
  {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context)=> EditExpenseScreen(
            expense: expenses[index],
            onSave: (editedExpense){
              setState(() {
                totalAmount += editedExpense.amount - expenses[index].amount;
                expenses[index] = editedExpense;
                totalController.text = totalAmount.toString();
              });
            }
        ),
      ),
    );
  }

  // new function - Date and time picker on textfield
  _selectDate() async{
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if(pickedDate!=null && pickedTime != null){
      setState(() {
        txtDateController.text =
        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day} "
            "${pickedTime.hour}:${pickedTime.minute}:00";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      _showMessage("Welcome ${widget.username}");

      totalController.clear();

      RequestController req = RequestController(
          path: "/api/timezone/Asia/Kuala_Lumpur",
          server: "http://worldtimeapi.org");
      req.get().then((value){
        dynamic res = req.result();
        txtDateController.text = res["datetime"].toString().substring(0,19).replaceAll('T', ' ');
      });

      expenses.addAll(await Expense.loadAll());

      setState(() {
        calculateTotal();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Daily Expenses'),

        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Amount (RM)',
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                keyboardType: TextInputType.datetime,
                controller: txtDateController,
                readOnly: true,
                onTap: _selectDate,
                decoration: const InputDecoration(
                    labelText: "Date"
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: totalController,
                // enabled: false, //disable from editing text in text field
                decoration: InputDecoration(
                  labelText: 'Total Spend (RM)',
                ),
              ),
            ),

            ElevatedButton(
                onPressed: _addExpense,
                child: Text('Add Expense')
            ),

            Container(
              child: _buildListView(),
            ),
          ],
        )
    );
  }


  Widget _buildListView() {
    return Expanded(
      child: ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: Key(expenses[index].id.toString()),
              background: Container(
                  color: Colors.red,
                  child: Center(
                      child: Text("Delete", style: TextStyle(
                          color: Colors.white
                      ))
                  )
              ),
              onDismissed: (direction) {
                _removeExpense(index);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Item dismissed")));
              },
              child: Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(expenses[index].desc),
                  subtitle: Row(
                    children: [
                      Text('Amount: ${expenses[index].amount}'),
                      const Spacer(),
                      Text('Date: ${expenses[index].dateTime}')
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: ()=> _removeExpense(index),
                  ),
                  onLongPress: (){
                    _editExpense(index);
                  },
                ),
              ),
            );
          }
      ),
    );
  }
}

class EditExpenseScreen extends StatelessWidget {
  //const EditExpenseScreen({super.key});
  final Expense expense;
  final Function(Expense) onSave;

  EditExpenseScreen({required this.expense, required this.onSave});

  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController txtDateController = TextEditingController();
  final TextEditingController idController = TextEditingController();



  @override
  Widget build(BuildContext context) {

    descController.text = expense.desc;
    amountController.text = expense.amount.toString();
    txtDateController.text = expense.dateTime;
    idController.text = expense.id.toString();

    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Expense'),
        ),
        body:
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                  )
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount (RM)',
                  )
              ),
            ),


            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                keyboardType: TextInputType.datetime,
                controller: txtDateController,
                readOnly: true,
                decoration: const InputDecoration(
                    labelText: "Date"
                ),
              ),
            ),

            ElevatedButton(onPressed: () async{
              Expense exp = Expense(int.parse(idController.text) as int?,double.parse(amountController.text) as double, descController.text, txtDateController.text);
              onSave(exp);
              await exp.update();
              Navigator.pop(context);
            }, child: Text("Save"))
          ],
        )
    );
  }
}