const sql = require('mssql');

class ExpenseService {
    constructor(pool) {
        this.pool = pool;
    }

    async get(ids = []) {
        let query = 'SELECT e.id, e.amount, e.purchase, e.note, e.date, c.id AS category_id, c.name AS category_name FROM expenses e LEFT JOIN categories c ON e.category_id = c.id ORDER BY e.date DESC';
        const request = this.pool.request();
        if (ids.length > 0) {
            query += ` WHERE id IN (${ids.map((_, i) => `@id${i}`).join(',')})`;
            ids.forEach((id, i) => request.input(`id${i}`, sql.Int, id));
        }

        const result = await request.query(query);
        return result.recordset ?? [];
    }

    async add(expense) {
        const {amount, purchase, category_id, note, date} = expense;
        console.log(`category_id: ${category_id}`);
        const result = await this.pool.request()
            .input("amount", sql.Float, amount)
            .input("purchase", sql.VarChar(255), purchase)
            .input("category_id", sql.Int, category_id)
            .input("note", sql.VarChar, note)
            .input("date", sql.DateTime, new Date(date))
            .query("INSERT INTO expenses (amount, purchase, category_id, note, date) OUTPUT INSERTED.* VALUES (@amount, @purchase, @category_id, @note, @date)");
            return result.recordset[0];

    }

    async update(id, expense) {
        const {amount, purchase, category_id, note, date } = expense;
        const result = await this.pool.request()
        .input('id', sql.Int, id)
        .input('amount', sql.Float, amount)
        .input('purchase', sql.VarChar(255), purchase)
        .input('category_id', sql.Int, category_id)
        .input('note', sql.VarChar, note)
        .input('date', sql.DateTime, date)
        .query(`UPDATE expenses
            SET amount=@amount, purchase=@purchase, category_id=@category_id, note=@note, date=@date OUTPUT INSERTED.* WHERE id=@id; SELECT * FROM expenses WHERE id=@id;`
        );
        return result.recordset[0];
    }

    async delete(ids = []) {
        let query = 'DELETE FROM expenses';
        const request = this.pool.request();
        if (ids.length > 0) {
            query += ` WHERE id IN (${ids.map((_, i) => `@id${i}`).join(',')})`;
            ids.forEach((id, i) => request.input(`id${i}`, sql.Int, id));
        }
        await request.query(query);
    }
}

module.exports = ExpenseService;