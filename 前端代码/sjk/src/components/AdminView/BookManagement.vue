<template>
    <div>
        <div class="header">
            图书类别管理 (ISBN)
        </div>
        <div class="body">
            <div style="margin-bottom: 10px;">
                <el-button icon="el-icon-plus" size="small" type="success" @click="showAddDialog">添加新书种</el-button>
            </div>
            
            <el-table :data="bookCategoryList" style="width: 100%" class="table" border>
                <el-table-column prop="isbn" label="ISBN" width="180" align="center"></el-table-column>
                <el-table-column prop="book_name" label="书名" width="250" align="center"></el-table-column>
                <el-table-column prop="author" label="作者" width="200" align="center"></el-table-column>
                <el-table-column prop="publisher" label="出版社" align="center"></el-table-column>
                <el-table-column prop="total_quantity" label="馆藏总数" width="100" align="center"></el-table-column>
                <el-table-column prop="borrowable_quantity" label="可借数量" width="100" align="center"></el-table-column>
                <el-table-column label="操作" width="220" align="center">
                    <template slot-scope="scope">
                        <el-button size="mini" type="primary" @click="showInstanceDialog(scope.row)">管理复本</el-button>
                        <el-button size="mini" type="warning" @click="showEditDialog(scope.row)">修改</el-button>
                        <el-button size="mini" type="danger" @click="showDeleteDialog(scope.row)">删除</el-button>
                    </template>
                </el-table-column>
            </el-table>

            <!-- 添加书种的对话框 -->
            <el-dialog title="添加新书种" :visible.sync="dialog.add" width="40%">
                <el-form :model="addForm" ref="addFormRef" :rules="formRules" label-width="100px">
                    <el-form-item label="ISBN" prop="isbn"><el-input v-model="addForm.isbn"></el-input></el-form-item>
                    <el-form-item label="书名" prop="book_name"><el-input v-model="addForm.book_name"></el-input></el-form-item>
                    <el-form-item label="图书类别" prop="category"><el-input v-model="addForm.category"></el-input></el-form-item>
                    <el-form-item label="作者" prop="author"><el-input v-model="addForm.author"></el-input></el-form-item>
                    <el-form-item label="出版社" prop="publisher"><el-input v-model="addForm.publisher"></el-input></el-form-item>
                    <el-form-item label="出版日期" prop="publish_date"><el-date-picker v-model="addForm.publish_date" type="date" placeholder="选择日期" value-format="yyyy-MM-dd"></el-date-picker></el-form-item>
                    <el-form-item label="价格" prop="price"><el-input v-model="addForm.price"></el-input></el-form-item>
                    <el-form-item label="图书简介" prop="intro"><el-input type="textarea" v-model="addForm.intro"></el-input></el-form-item>
                </el-form>
                <div slot="footer" class="dialog-footer">
                    <el-button @click="dialog.add = false">取 消</el-button>
                    <el-button type="primary" @click="addBookCategory">确 定</el-button>
                </div>
            </el-dialog>

            <!-- 修改书种的对话框 -->
            <el-dialog title="修改图书信息" :visible.sync="dialog.edit" width="40%">
                <el-form :model="editForm" ref="editFormRef" :rules="formRules" label-width="100px">
                    <el-form-item label="ISBN"><span>{{ editForm.isbn }}</span></el-form-item>
                    <el-form-item label="书名" prop="book_name"><el-input v-model="editForm.book_name"></el-input></el-form-item>
                    <el-form-item label="图书类别" prop="category"><el-input v-model="editForm.category"></el-input></el-form-item>
                    <el-form-item label="作者" prop="author"><el-input v-model="editForm.author"></el-input></el-form-item>
                    <el-form-item label="出版社" prop="publisher"><el-input v-model="editForm.publisher"></el-input></el-form-item>
                    <el-form-item label="出版日期" prop="publish_date"><el-date-picker v-model="editForm.publish_date" type="date" placeholder="选择日期" value-format="yyyy-MM-dd"></el-date-picker></el-form-item>
                    <el-form-item label="价格" prop="price"><el-input v-model="editForm.price"></el-input></el-form-item>
                    <el-form-item label="图书简介" prop="intro"><el-input type="textarea" v-model="editForm.intro"></el-input></el-form-item>
                </el-form>
                <div slot="footer" class="dialog-footer">
                    <el-button @click="dialog.edit = false">取 消</el-button>
                    <el-button type="primary" @click="editBookCategory">确 定 修 改</el-button>
                </div>
            </el-dialog>

            <!-- 删除书种的对话框 -->
            <el-dialog title="删除确认" :visible.sync="dialog.delete" width="30%">
                <span>确定要删除《{{ categoryToDelete.book_name }}》这个书种吗？<br><small style="color:red;">注意：这将同时删除所有关联的实体书复本！</small></span>
                <div slot="footer" class="dialog-footer">
                    <el-button @click="dialog.delete = false">取 消</el-button>
                    <el-button type="danger" @click="deleteBookCategory">确 定 删 除</el-button>
                </div>
            </el-dialog>

            <!-- 管理复本的对话框 -->
            <el-dialog title="管理实体书复本" :visible.sync="instanceDialog.visible" width="50%">
                <h4>《{{ instanceDialog.bookName }}》</h4>
                <el-form :inline="true" :model="newInstance" ref="instanceFormRef" size="small">
                    <el-form-item label="新书号" prop="book_id">
                        <el-input v-model="newInstance.book_id" placeholder="请输入唯一的实体书号"></el-input>
                    </el-form-item>
                    <el-form-item>
                        <el-button type="primary" @click="addInstance">添加入库</el-button>
                    </el-form-item>
                </el-form>

                <el-table :data="instanceDialog.instances" border height="250">
                    <el-table-column property="book_id" label="实体书号"></el-table-column>
                    <el-table-column property="status" label="状态"></el-table-column>
                    <el-table-column label="操作">
                        <template slot-scope="scope">
                            <el-button 
                                size="mini" 
                                type="danger" 
                                @click="deleteInstance(scope.row)" 
                                :disabled="scope.row.status === '已借出'">
                                删除
                            </el-button>
                        </template>
                    </el-table-column>
                </el-table>
                 <div slot="footer">
                    <el-button @click="instanceDialog.visible = false">关 闭</el-button>
                </div>
            </el-dialog>
        </div>
    </div>
</template>

<script>
export default {
    name: 'BookCategoryManagement',
    created() {
        this.fetchBookCategories();
    },
    data() {
        return {
            bookCategoryList: [],
            dialog: { add: false, edit: false, delete: false },
            addForm: {
                isbn: '',
                book_name: '',
                category: '',
                author: '',
                publisher: '',
                publish_date: '',
                price: '',
                intro: '',
                total_quantity: 0 // 添加书种时不直接添加数量，此字段保留用于未来扩展
            },
            editForm: {},
            categoryToDelete: {},
            formRules: {
                isbn: [{ required: true, message: 'ISBN是必填项', trigger: 'blur' }],
                book_name: [{ required: true, message: '书名是必填项', trigger: 'blur' }],
            },
            instanceDialog: {
                visible: false,
                bookName: '',
                isbn: '',
                instances: []
            },
            newInstance: {
                book_id: '',
                isbn: ''
            }
        }
    },
    methods: {
        fetchBookCategories() {
            this.$axios.get("/api/books/search").then(res => {
                if (res.data.status === 200) {
                    this.bookCategoryList = res.data.tabledata;
                }
            });
        },
        // --- 添加功能 ---
        showAddDialog() {
            this.dialog.add = true;
            this.$nextTick(() => {
                if (this.$refs.addFormRef) {
                   this.$refs.addFormRef.resetFields();
                }
            });
        },
        addBookCategory() {
            this.$refs.addFormRef.validate(valid => {
                if (valid) {
                    this.$axios.post("/api/admin/book_category", this.addForm).then(res => {
                        if (res.data.status === 200) {
                            this.$message.success("添加成功");
                            this.dialog.add = false;
                            this.fetchBookCategories();
                        } else {
                            this.$message.error(res.data.msg);
                        }
                    });
                }
            });
        },
        // --- 修改功能 ---
        showEditDialog(row) {
            // 注意：这里不获取已借出数量，因为修改书种信息不应影响复本数量
            this.editForm = { ...row };
            this.dialog.edit = true;
        },
        editBookCategory() {
            this.$refs.editFormRef.validate(valid => {
                if (valid) {
                    this.$axios.put("/api/admin/book_category", this.editForm).then(res => {
                        if (res.data.status === 200) {
                            this.$message.success("修改成功");
                            this.dialog.edit = false;
                            this.fetchBookCategories();
                        } else {
                            this.$message.error(res.data.msg);
                        }
                    });
                }
            });
        },
        // --- 删除功能 ---
        showDeleteDialog(row) {
            this.categoryToDelete = { ...row };
            this.dialog.delete = true;
        },
        deleteBookCategory() {
            this.$axios.delete("/api/admin/book_category", { data: { isbn: this.categoryToDelete.isbn } }).then(res => {
                if (res.data.status === 200) {
                    this.$message.success("删除成功");
                    this.dialog.delete = false;
                    this.fetchBookCategories();
                } else {
                    this.$message.error(res.data.msg);
                }
            });
        },
        // --- 管理复本功能 ---
        showInstanceDialog(bookCategory) {
            this.instanceDialog.bookName = bookCategory.book_name;
            this.instanceDialog.isbn = bookCategory.isbn;
            this.newInstance.isbn = bookCategory.isbn;
            this.newInstance.book_id = '';

            this.$axios.get("/api/admin/instances", { params: { isbn: bookCategory.isbn } })
                .then(res => {
                    if (res.data.status === 200) {
                        this.instanceDialog.instances = res.data.instances;
                        this.instanceDialog.visible = true;
                    } else {
                        this.$message.error("获取复本列表失败");
                    }
                });
        },
        addInstance() {
            if (!this.newInstance.book_id) {
                this.$message.warning("请输入实体书号");
                return;
            }
            this.$axios.post("/api/admin/instances", this.newInstance).then(res => {
                if (res.data.status === 200) {
                    this.$message.success("入库成功！");
                    this.newInstance.book_id = '';
                    this.showInstanceDialog({ isbn: this.instanceDialog.isbn, book_name: this.instanceDialog.bookName });
                    this.fetchBookCategories();
                } else {
                    this.$message.error(res.data.msg);
                }
            });
        },
        deleteInstance(instance) {
            this.$confirm(`确定要删除书号为 "${instance.book_id}" 的这本实体书吗？`, '删除确认', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
            }).then(() => {
                this.$axios.delete("/api/admin/instances", { data: { book_id: instance.book_id } }).then(res => {
                    if (res.data.status === 200) {
                        this.$message.success("删除成功！");
                        this.showInstanceDialog({ isbn: this.instanceDialog.isbn, book_name: this.instanceDialog.bookName });
                        this.fetchBookCategories();
                    } else {
                        this.$message.error(res.data.msg);
                    }
                });
            }).catch(() => {});
        }
    }
}
</script>

<style scoped>
.header { text-align: center; font-size: 20px; font-weight: 800; border-bottom: 1px solid #e3e3e3; padding: 20px; }
.body { width: 95%; margin: 20px auto; }
</style>