<template>
    <div>
        <div class="header">
            图书查询与借阅
        </div>
        <div class="body">
            <!-- 表格显示的是 book_category 表的内容 -->
            <el-table :data="bookCategoryList" style="width: 100%" class="table" border>
                <el-table-column prop="isbn" label="ISBN" width="180" align="center"></el-table-column>
                <el-table-column prop="book_name" label="书名" width="250" align="center"></el-table-column>
                <el-table-column prop="author" label="作者" width="200" align="center"></el-table-column>
                <el-table-column prop="publisher" label="出版社" width="250" align="center"></el-table-column>
                <el-table-column prop="borrowable_quantity" label="可借数量" width="120" align="center"></el-table-column>
                
                <el-table-column label="操作" align="center">
                    <template slot-scope="scope">
                        <!-- 点击按钮，会先获取可借的复本列表，再显示弹窗 -->
                        <el-button 
                            icon="el-icon-plus" 
                            size="small" 
                            type="success" 
                            @click="showBorrowDialog(scope.row)"
                            :disabled="scope.row.borrowable_quantity === 0">
                            {{ scope.row.borrowable_quantity > 0 ? '借阅' : '已借完' }}
                        </el-button>
                    </template>
                </el-table-column>
            </el-table>

            <!-- 【新增】选择具体书号进行借阅的弹窗 -->
            <el-dialog title="选择要借阅的图书" :visible.sync="borrowDialog.visible" width="30%">
                <el-form label-width="100px">
                    <el-form-item label="您将借阅:">
                        <strong>《{{ borrowDialog.bookName }}》</strong>
                    </el-form-item>
                    <el-form-item label="可选书号:">
                        <el-select v-model="borrowDialog.selectedBookId" placeholder="请选择一本">
                            <el-option
                                v-for="item in borrowDialog.availableInstances"
                                :key="item"
                                :label="item"
                                :value="item">
                            </el-option>
                        </el-select>
                    </el-form-item>
                </el-form>
                <div slot="footer" class="dialog-footer">
                    <el-button @click="borrowDialog.visible = false">取 消</el-button>
                    <el-button type="primary" @click="handleBorrowConfirm" :disabled="!borrowDialog.selectedBookId">
                        确认借阅
                    </el-button>
                </div>
            </el-dialog>
        </div>
    </div>
</template>

<script>
export default {
    name: 'BookSearchAndBorrowPro',
    created() {
        this.fetchBookCategories();
    },
    data() {
        return {
            bookCategoryList: [],
            borrowDialog: {
                visible: false,
                bookName: '',
                isbn: '',
                availableInstances: [], // 存放可借的实体书号列表
                selectedBookId: '' // 用户选择的实体书号
            }
        }
    },
    methods: {
        fetchBookCategories() {
            // API 修正: 指向新的查询接口
            this.$axios.get("/api/books/search").then((res) => {
                if (res.data.status === 200) {
                    this.bookCategoryList = res.data.tabledata;
                }
            }).catch(error => {
                console.error("Error fetching book categories:", error);
                this.$message.error('网络错误，获取图书列表失败');
            });
        },
        showBorrowDialog(book) {
            // 1. 先重置弹窗数据
            this.borrowDialog.bookName = book.book_name;
            this.borrowDialog.isbn = book.isbn;
            this.borrowDialog.availableInstances = [];
            this.borrowDialog.selectedBookId = '';
            
            // 2. 调用新API，获取这本书有哪些具体的复本是可借的
            this.$axios.get("/api/books/available_instances", { params: { isbn: book.isbn } })
                .then(res => {
                    if (res.data.status === 200 && res.data.instances.length > 0) {
                        this.borrowDialog.availableInstances = res.data.instances;
                        this.borrowDialog.visible = true; // 获取到数据后再显示弹窗
                    } else {
                        this.$message.error('暂无更多可借阅的复本');
                    }
                })
                .catch(error => {
                     console.error("Error fetching available instances:", error);
                     this.$message.error('查询可借复本失败');
                });
        },
        handleBorrowConfirm() {
            // 用户在弹窗中点击了“确认借阅”
            const bookId = this.borrowDialog.selectedBookId;
            if (!bookId) {
                this.$message.warning('请先选择一个书号');
                return;
            }

            // 调用新的借阅接口，参数是具体的 book_id
            this.$axios.post("/api/borrow/create", { book_id: bookId }).then((res) => {
                if (res.data.status === 200) {
                    this.$message.success("借阅成功!");
                    this.borrowDialog.visible = false;
                    this.fetchBookCategories(); // 刷新图书类别列表以更新可借阅数量
                } else {
                    this.$message.error(res.data.msg || "借阅失败");
                }
            }).catch(error => {
                console.error("Error borrowing book:", error);
                this.$message.error('网络错误，借阅失败');
            });
        }
    }
}
</script>

<style scoped>
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