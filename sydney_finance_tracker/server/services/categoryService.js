const sql = require('mssql');

class CategoryService {
    constructor(pool) {
        this.pool = pool;
    }

    async get(ids = []) {
        console.log("Get Reminder");
        let query = 'SELECT * FROM categories';
        const request = this.pool.request();

        if (ids.length > 0) {
            query +=   ` WHERE id IN (${ids.map((_, i) => `@id${i}`).join(',')})`;
            ids.forEach((id, i) => request.input(`id${i}`, sql.Int, id));
        }
        
        const result = await request.query(query);
        return result.recordset ?? [];
    }

    async add(category) {
        const { name } = category;
        console.log("Adding Reminder");
        const result = await this.pool.request()
            .input('name', sql.VarChar(20), name)
            .query('INSERT INTO categories (name) OUTPUT INSERTED.* VALUES (@name);');
        console.log(result);
        console.log(result.recordset)
        return result.recordset[0];
    }

    async delete(ids = []) {
        let query = 'DELETE FROM categories';
        const request = this.pool.request();
        if (ids.length > 0) {
            query += ` WHERE id IN (${ids.map((_, i) => `@id${i}`).join(',')})`;
            ids.forEach((id, i) => request.input(`id${i}`, sql.Int, id));
        }

        await request.query(query);
    }
}

module.exports = CategoryService;