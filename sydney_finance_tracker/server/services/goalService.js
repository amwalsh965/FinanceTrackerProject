const sql = require('mssql');

class GoalService {
    constructor(pool) {
        this.pool = pool;
    }

    calculateEndDate(duration_type, custom_duration=null) {
        const now = new Date();

        switch (duration_type) {
            case 'weekly': {
                const day = now.getDay();
                const diff = 6 - day;
                const end = new Date(now);
                end.setDate(now.getDate() + diff + 1);
                end.setHours(23, 59, 59, 999);
                return end;
            }
            case 'monthly': {
                const end = new Date(now.getFullYear(), now.getMonth() + 1, 0);
                end.setHours(23, 59, 59, 999);
                return end;
            }
            case 'yearly': {
                const end = new Date(now.getFullYear(), 11, 31);
                end.setHours(23, 59, 59, 999);
                return end;
            } case 'custom': {
                if (!custom_duration) return null;
                const end = new Date(now);
                end.setDate(now.getDate() + custom_duration);
                end.setHours(23, 59, 59, 999);
                return end;
            }
            default: return null;
        }
    }

    async get(ids = []) {
        console.log("GET");
        let query = 'SELECT g.id, g.spending_goal, g.reoccuring, g.end_date, g.duration_type, g.custom_duration, c.id AS category_id, c.name FROM goals g LEFT JOIN categories c ON g.category_id = c.id ORDER BY g.id';
        const request = this.pool.request();

        if (ids.length > 0) {
            query +=   ` WHERE id IN (${ids.map((_, i) => `@id${i}`).join(',')})`;
            ids.forEach((id, i) => request.input(`id${i}`, sql.Int, id));
        }
        
        const result = await request.query(query);
        return result.recordset ?? [];
    }

    async add(goal) {
        console.log(goal);
        const { category_id, spending_goal, reoccuring, duration_type, custom_duration} = goal;

        

        const end_date = this.calculateEndDate(duration_type, custom_duration);
        console.log("Add");
        const result = await this.pool.request()
            .input('category_id', sql.Int, category_id)
            .input('spending_goal', sql.Int, spending_goal)
            .input('reoccuring', sql.Bit, reoccuring)
            .input('end_date', sql.DateTime, end_date)
            .input('duration_type', sql.NVarChar(20), duration_type)
            .input('custom_duration', sql.Int, custom_duration)
            .query(`INSERT INTO goals (category_id, spending_goal, reoccuring, end_date, duration_type, custom_duration) OUTPUT INSERTED.* 
                VALUES (@category_id, @spending_goal, @reoccuring, @end_date, @duration_type, @custom_duration);`);
        console.log(result);
        console.log(result.recordset)
        return result.recordset[0];
    }

    async update(id, goal) {
        const { category_id, spending_goal, reoccuring, duration_type, custom_duration } = goal;

        const end_date = this.calculateEndDate(duration_type, custom_duration);
        const result = await this.pool.request()
        .input('id', sql.Int, id)
        .input('spending_goal', sql.Int, spending_goal)
        .input('reoccuring', sql.Bit, reoccuring)
        .input('end_date', sql.DateTime, end_date)
        .input('duration_type', sql.NVarChar(20), duration_type)
        .input('custom_duration', sql.Int, custom_duration)
        .query(`
            UPDATE goals
            SET spending_goal=@spending_goal, reoccuring=@reoccuring, end_date=@end_date, duration_type=@duration_type, custom_duration=@custom_duration WHERE id=@id;
            SELECT * FROM goals WHERE id=@id`);
        return result.recordset[0];
    }

    async delete(ids = []) {
        let query = 'DELETE FROM goals';
        const request = this.pool.request();
        if (ids.length > 0) {
            query += ` WHERE id IN (${ids.map((_, i) => `@id${i}`).join(',')})`;
            ids.forEach((id, i) => request.input(`id${i}`, sql.Int, id));
        }

        await request.query(query);
    }

}

module.exports = GoalService;