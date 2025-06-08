<template>
    <div>
        <div class="header">
            全部借阅记录管理
        </div>
        <div class="body">
            <el-table :data="recordList" style="width: 100%" class="table" border>
                <el-table-column prop="record_id" label="记录ID" width="100" align="center"></el-table-column>
                <el-table-column prop="book_name" label="书名" width="250" align="center"></el-table-column>
                <el-table-column prop="reader_name" label="借阅人" width="150" align="center"></el-table-column>
                <el-table-column prop="borrow_date" label="借阅时间" align="center"></el-table-column>
                <el-table-column prop="due_date" label="应还日期" align="center"></el-table-column>
                <el-table-column prop="status" label="状态" width="120" align="center">
                    <template slot-scope="scope">
                        <el-tag :type="scope.row.status === '借阅中' ? 'warning' : 'success'" disable-transitions>
                            {{ scope.row.status }}
                        </el-tag>
                    </template>
                </el-table-column>
            </el-table>
        </div>
    </div>
</template>

<script>
export default {
    name: 'RecordManagement',
    created() {
        this.fetchRecords();
    },
    data() {
        return {
            recordList: [],
        }
    },
    methods: {
        fetchRecords() {
            // 调用我们刚刚在后端创建的API
            this.$axios.get("/api/admin/all_records").then((res) => {
                if (res.data.status === 200) {
                    this.recordList = res.data.tabledata;
                } else {
                    this.$message.error('获取所有借阅记录失败');
                }
            }).catch(error => {
                console.error("Error fetching all records:", error);
                this.$message.error('网络错误，无法获取记录');
            })
        }
    }
}
</script>

<style scoped>
.header { text-align: center; font-size: 20px; font-weight: 800; border-bottom: 1px solid #e3e3e3; padding: 20px; }
.body { width: 95%; margin: 20px auto; }
</style>