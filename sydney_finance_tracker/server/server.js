const express = require("express");
const cors = require("cors");
const sql = require('mssql');
const ExpenseService = require('./services/expenseService');
const ReminderService = require('./services/reminderService');
const GoalService = require('./services/goalService');
const CategoryService = require('./services/categoryService');

const app = express();
app.use(cors());
app.use(express.json());

const config = {
  user: 'node_user',
  password: 'Password123!',
  server: 'localhost',
  port: 1433,
  database: 'finance_tracker',
  options: {
    encrypt: false,
    trustedConnection: true,
    trustServerCertificate: true
  }
};

sql.connect(config).then(pool => {
    console.log('Connected to SQL Server');

    const expenseService = new ExpenseService(pool);
    const reminderService = new ReminderService(pool);
    const goalService = new GoalService(pool);
    const categoryService = new CategoryService(pool);

    app.get('/expenses', async (req, res) => {
        try {
            const ids = req.query.ids ? req.query.ids.split(',').map(id => parseInt(id)) : [];
            const expenses = await expenseService.get(ids);
            res.json(expenses);
        } catch(err) { res.status(500).send(err.message); }
    });

    app.post('/expenses', async (req, res) => {
        try {
            const expense = await expenseService.add(req.body);
            res.json(expense);
        } catch(err) { res.status(500).send(err.message); }
    });

    app.put('/expenses/:id', async (req, res) => {
        try {
            const updated = await expenseService.update(req.params.id, req.body);
            res.json(updated);
        } catch(err) { res.status(500).send(err.message);}
    });

    app.delete('/expenses', async (req, res) => {
        try {
            const ids = req.body.ids || [];
            await expenseService.delete(ids);
            res.sendStatus(204);
        } catch(err) { res.status(500).send(err.message); }
    });

    app.get('/reminders', async (req, res) => {
        console.log("Server get");
        try {
            const ids = req.query.ids ? req.query.ids.split(',').map(id => parseInt(id)) : [];
            const reminders = await reminderService.get(ids);
            res.json(reminders);
        } catch(err) { res.status(500).send(err.message); }
    });

    app.get('/reminders/first', async (req, res) => {
        console.log("Server get first");
        try {
            const firstReminder = await reminderService.getFirstByDate();
            res.json(firstReminder || null);
        } catch(err) {
            res.status(500).send(err.message);
        }
    });

    app.post('/reminders', async (req, res) => {
        console.log("Server post");
        try {
            const reminder = await reminderService.add(req.body);
            res.json(reminder);
        } catch(err) { res.status(500).send(err.message); }
    });

    app.put('/reminders/:id', async (req, res) => {
        try {
            const updated = await reminderService.update(req.params.id, req.body);
            res.json(updated);
        } catch(err) { res.status(500).send(err.message);}
    });

    app.delete('/reminders', async (req, res) => {
        try {
            const ids = req.body.ids || [];
            await reminderService.delete(ids);
            res.sendStatus(204);
        } catch(err) { res.status(500).send(err.message); }
    });

    //goals
    app.get('/goals', async (req, res) => {
        try {
            const ids = req.query.ids ? req.query.ids.split(',').map(id => parseInt(id)) : [];
            const goals = await goalService.get(ids);
            res.json(goals);
        } catch(err) { res.status(500).send(err.message); }
    });

    app.post('/goals', async (req, res) => {
        try {
            const goal = await goalService.add(req.body);
            res.json(goal);
        } catch(err) { res.status(500).send(err.message); }
    });

    app.put('/goals/:id', async (req, res) => {
        try {
            const updated = await goalService.update(req.params.id, req.body);
            res.json(updated);
        } catch(err) { res.status(500).send(err.message);}
    });

    app.delete('/goals', async (req, res) => {
        try {
            const ids = req.body.ids || [];
            await goalService.delete(ids);
            res.sendStatus(204);
        } catch(err) { res.status(500).send(err.message); }
    });

    //category
    app.get('/categories', async (req, res) => {
        try {
            const ids = req.query.ids ? req.query.ids.split(',').map(id => parseInt(id)) : [];
            const categories = await categoryService.get(ids);
            res.json(categories);
        } catch(err) { res.status(500).send(err.message); }
    });

    app.post('/categories', async (req, res) => {
        try {
            const category = await categoryService.add(req.body);
            res.json(category);
        } catch(err) { res.status(500).send(err.message); }
    });

    app.delete('/categories', async (req, res) => {
        try {
            const ids = req.body.ids || [];
            await categoryService.delete(ids);
            res.sendStatus(204);
        } catch(err) { res.status(500).send(err.message); }
    });

    
    const PORT = 3000;
    app.listen(PORT, () => {console.log(`Server running on port ${PORT}`);});
});

