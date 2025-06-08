<template>
    <div>
        <div class="header">
            我的借阅记录
        </div>
        <div class="body">
            <!-- <<< 修改: 表格更新为借阅记录信息 >>> -->
            <el-table :data="borrowRecords" style="width: 100%" class="table" border>
                <el-table-column prop="book_name" label="书名" width="250" align="center"></el-table-column>
                <el-table-column prop="author" label="作者" width="200" align="center"></el-table-column>
                <el-table-column prop="borrow_date" label="借阅日期" width="200" align="center"></el-table-column>
                <el-table-column prop="due_date" label="应还日期" width="200" align="center"></el-table-column>
                
                <el-table-column prop="status" label="状态" width="120" align="center">
                    <template slot-scope="scope">
                        <!-- <<< 修改: 根据状态显示不同颜色标签，更美观 >>> -->
                        <el-tag :type="scope.row.status === '借阅中' ? 'warning' : 'success'" disable-transitions>
                            {{ scope.row.status }}
                        </el-tag>
                    </template>
                </el-table-column>

                <el-table-column label="操作" align="center">
                    <template slot-scope="scope">
                        <!-- <<< 修改: 只有“借阅中”的记录才显示“归还”按钮 >>> -->
                        <el-button 
                            v-if="scope.row.status === '借阅中'"
                            size="small" 
                            type="primary" 
                            @click="handleReturn(scope.row)">
                            归还
                        </el-button>
                    </template>
                </el-table-column>
            </el-table>
        </div>
    </div>
</template>

<script>
export default {
    name: 'MyBorrowRecords',
    props: {
        // 【新增】从父组件接收一个“是否可见”的信号
        isActive: {
            type: Boolean,
            default: false,
        }
    },
    data() {
        return {
            borrowRecords: [],
            hasLoaded: false // 【新增】一个状态，防止不必要的重复加载
        }
    },
    watch: {
        // 【核心修改】使用 watch 侦听 isActive 属性的变化
        isActive: {
            handler(newVal) {
                // 当这个组件变为可见 (isActive变为true)，并且从未加载过数据时，才去请求
                if (newVal && !this.hasLoaded) {
                    this.fetchMyRecords();
                }
            },
            immediate: true // 【重要】立即执行一次 handler，保证首次加载
        }
    },
    methods: {
        fetchMyRecords() {
            this.$axios.get("/api/borrow/my_records").then((res) => {
                if (res.data.status === 200) {
                    this.borrowRecords = res.data.tabledata;
                    this.hasLoaded = true; // 标记为已加载
                } else {
                    this.$message.error('获取借阅记录失败');
                }
            }).catch(error => {
                console.error("Error fetching records:", error);
                this.$message.error('网络错误，无法获取借阅记录');
            });
        },
        handleReturn(record) {
            this.$confirm(`您确定要归还《${record.book_name}》吗?`, '归还确认', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'info'
            }).then(() => {
                this.$axios.post("/api/borrow/return", { record_id: record.record_id }).then(res => {
                    if (res.data.status === 200) {
                        this.$message.success('归还成功！');
                        // 归还成功后，重置加载状态并重新获取数据
                        this.hasLoaded = false;
                        this.fetchMyRecords(); 
                    } else {
                        this.$message.error(res.data.msg || '归还失败');
                    }
                });
            }).catch(() => {
                this.$message.info('已取消归还操作');          
            });
        }
    }
}
</script>
<style scoped>
/* 样式可以保持大部分不变，按需微调 */
.header {
    width: 100%;
    height: 10%;
    text-align: center;
    line-height: 64px;
    font-size: 20px;
    font-weight: 800;
    border-bottom: 1px solid #e3e3e3;
}

.body {
    width: 90%;
    margin: 20px auto;
}
</style>