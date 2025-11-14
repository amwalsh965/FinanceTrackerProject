const sql = require('mssql');

class ReminderService {
    constructor(pool) {
        this.pool = pool;
    }

    async get(ids = []) {
        console.log("GET");
        let query = `SELECT r.id, r.title, r.content, g.id AS 
        goal_id, g.spending_goal AS spending_goal, g.end_date AS end_date, c.id AS category_id, c.name AS category_name FROM reminders r LEFT JOIN goals g ON r.goal_id = g.id
        LEFT JOIN categories c ON g.category_id = c.id ORDER BY r.id`;
        const request = this.pool.request();

        if (ids.length > 0) {
            query +=   ` WHERE id IN (${ids.map((_, i) => `@id${i}`).join(',')})`;
            ids.forEach((id, i) => request.input(`id${i}`, sql.Int, id));
        }
        
        const result = await request.query(query);
        return result.recordset ?? [];
    }

    async add(reminder) {
        const { title, content, goal_id } = reminder;
        console.log("Add");
        const result = await this.pool.request()
            .input('title', sql.NVarChar(225), title)
            .input('content', sql.NVarChar(225), content)
            .input('goal_id', sql.Int, goal_id)
            .query('INSERT INTO reminders (title, content, goal_id) OUTPUT INSERTED.* VALUES (@title, @content, @goal_id);');
        console.log(result);
        console.log(result.recordset)
        return result.recordset[0];
    }

    async update(id, reminder) {
        const { title, content } = reminder;
        const result = await this.pool.request()
        .input('id', sql.Int, id)
        .input('title', sql.NVarChar(sql.MAX), title)
        .input('content', sql.NVarChar(sql.MAX), content)
        .input('goal_id', sql.Int, goal_id)
        .query(`
            UPDATE reminders
            SET title=@title, content=@content, goal_id=@goal_id WHERE id=@id;
            SELECT * FROM reminders WHERE id=@id`);
        return result.recordset[0];
    }

    async delete(ids = []) {
        let query = 'DELETE FROM reminders';
        const request = this.pool.request();
        if (ids.length > 0) {
            query += ` WHERE id IN (${ids.map((_, i) => `@id${i}`).join(',')})`;
            ids.forEach((id, i) => request.input(`id${i}`, sql.Int, id));
        }

        await request.query(query);
    }

    async getFirstByDate() {
        console.log("Get first by id");
        const result = await this.pool.request().query('SELECT TOP 1 * FROM reminders ORDER BY id ASC');
        return result.recordset[0] || null;
    }
}

module.exports = ReminderService;