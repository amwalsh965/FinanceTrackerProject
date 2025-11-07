const sql = require('mssql');

class ExpenseService {
    constructor(pool) {
        this.pool = pool;
    }

    async get(ids = []) {
        let query = 'SELECT * FROM expenses';
        const request = this.pool.request();
        if (ids.length > 0) {
            query += ` WHERE id IN (${ids.map((_, i) => `@id${i}`).join(',')})`;
            ids.forEach((id, i) => request.input(`id${i}`, sql.Int, id));
        }

        const result = await request.query(query);
        return result.recordset;
    }

    async add(expense) {
        const {amount, purchase, category, note, date } = expense;
        const result = await this.pool.request()
            .input("amount", sql.Float, amount)
            .input("purchase", sql.VarChar(255), purchase)
            .input("category", sql.VarChar, category)
            .input("note", sql.VarChar, note)
            .input("date", sql.DateTime, new Date(date))
            .query("INSERT INTO expenses (amount, purchase, category, note, date) OUTPUT INSERTED.* VALUES (@amount, @purchase, @category, @note, @date)");
            return result.recordset[0];

    }

    async update(id, expense) {
        const {amount, purchase, category, note, date } = expense;
        const result = await this.pool.request()
        .input('id', sql.Int, id)
        .input('amount', sql.Float, amount)
        .input('purchase', sql.VarChar(255), purchase)
        .input('category', sql.VarChar, category)
        .input('note', sql.VarChar, note)
        .input('date', sql.DateTime, date)
        .query(`UPDATE expenses
            SET amount=@amount, purchase=@purchase, category=@category, note=@note, date=@date OUTPUT INSERTED.* WHERE id=@id; SELECT * FROM expenses WHERE id=@id;`
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