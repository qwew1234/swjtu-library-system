<template>
    <div>
        <div class="header">
            读者信息管理
        </div>
        <div class="body">
            <div style="margin-bottom: 10px;">
                <el-button icon="el-icon-plus" size="small" type="success" @click="showAddDialog">添加新读者</el-button>
            </div>
            
            <el-table :data="readerList" style="width: 100%" class="table" border>
                <el-table-column prop="reader_id" label="读者证号/学号" align="center"></el-table-column>
                <el-table-column prop="name" label="姓名" align="center"></el-table-column>
                <el-table-column prop="department" label="院系/部门" align="center"></el-table-column>
                <el-table-column prop="telephone" label="联系电话" align="center"></el-table-column>
                <el-table-column prop="role" label="角色" align="center">
                    <template slot-scope="scope">{{ scope.row.role === 1 ? '管理员' : '普通读者' }}</template>
                </el-table-column>
                <el-table-column prop="max_borrow_quantity" label="可借数量" align="center"></el-table-column>
                <el-table-column prop="borrowed_quantity" label="已借数量" align="center"></el-table-column>
                <el-table-column label="操作" width="150" align="center">
                    <template slot-scope="scope">
                        <el-button size="mini" type="warning" @click="showEditDialog(scope.row)">修改</el-button>
                        <el-button size="mini" type="danger" @click="showDeleteDialog(scope.row)">删除</el-button>
                    </template>
                </el-table-column>
            </el-table>

            <!-- 添加/修改读者的对话框 -->
            <el-dialog :title="dialog.title" :visible.sync="dialog.visible" width="40%">
                <el-form :model="form" ref="formRef" :rules="formRules" label-width="120px">
                    <el-form-item label="读者证号/学号" prop="reader_id">
                        <el-input v-model="form.reader_id" :disabled="dialog.isEdit"></el-input>
                    </el-form-item>
                    <el-form-item label="姓名" prop="name"><el-input v-model="form.name"></el-input></el-form-item>
                    <el-form-item label="初始密码" prop="password" v-if="!dialog.isEdit">
                        <el-input v-model="form.password" placeholder="若不填，默认为123456"></el-input>
                    </el-form-item>
                     <el-form-item label="重置密码" v-if="dialog.isEdit">
                        <el-input v-model="form.password" placeholder="若需重置密码，请在此输入新密码"></el-input>
                    </el-form-item>
                    <el-form-item label="院系/部门" prop="department"><el-input v-model="form.department"></el-input></el-form-item>
                    <el-form-item label="联系电话" prop="telephone"><el-input v-model="form.telephone"></el-input></el-form-item>
                    <el-form-item label="角色" prop="role">
                        <el-radio-group v-model="form.role">
                            <el-radio :label="0">普通读者</el-radio>
                            <el-radio :label="1">管理员</el-radio>
                        </el-radio-group>
                    </el-form-item>
                    <el-form-item label="最大可借数量" prop="max_borrow_quantity">
                        <el-input-number v-model="form.max_borrow_quantity" :min="0"></el-input-number>
                    </el-form-item>
                </el-form>
                <div slot="footer">
                    <el-button @click="dialog.visible = false">取 消</el-button>
                    <el-button type="primary" @click="handleSubmit">确 定</el-button>
                </div>
            </el-dialog>
        </div>
    </div>
</template>

<script>
export default {
    name: 'ReaderManagement',
    created() {
        this.fetchReaderData();
    },
    data() {
        return {
            readerList: [],
            dialog: { visible: false, title: '', isEdit: false },
            
            // 将表单数据模型提到顶层，并设置好所有字段
            form: {
                reader_id: '',
                name: '',
                password: '',
                department: '',
                telephone: '',
                role: 0,
                max_borrow_quantity: 5
            },

            formRules: {
                reader_id: [{ required: true, message: '读者证号是必填项', trigger: 'blur' }],
                name: [{ required: true, message: '姓名是必填项', trigger: 'blur' }],
                telephone: [{ required: true, message: '联系电话是必填项', trigger: 'blur' }],
            }
        };
    },
    methods: {
        fetchReaderData() {
            this.$axios.get("/api/admin/readers").then(res => {
                if (res.data.status === 200) {
                    this.readerList = res.data.tabledata;
                }
            });
        },
        
        // --- 【核心修正点在这里】 ---
        showAddDialog() {
            // 1. 先重置 form 对象，确保所有字段都被清空
            this.form = {
                reader_id: '',
                name: '',
                password: '',
                department: '',
                telephone: '',
                role: 0,
                max_borrow_quantity: 5
            };
            // 2. 更新对话框状态
            this.dialog = { visible: true, title: '添加新读者', isEdit: false };
            
            // 3. 使用 $nextTick 确保 DOM 更新完毕后，再清除表单的校验状态
            this.$nextTick(() => {
                if (this.$refs.formRef) {
                    this.$refs.formRef.clearValidate();
                }
            });
        },
        
        showEditDialog(row) {
            // 使用 Object.assign 来确保是新对象，并设置默认空密码
            this.form = Object.assign({}, row, { password: '' });
            this.dialog = { visible: true, title: '修改读者信息', isEdit: true };
            this.$nextTick(() => {
                if (this.$refs.formRef) {
                    this.$refs.formRef.clearValidate();
                }
            });
        },
        
        handleSubmit() {
            this.$refs.formRef.validate(valid => {
                if (valid) {
                    const url = "/api/admin/readers";
                    const method = this.dialog.isEdit ? "put" : "post";

                    // 创建一个干净的提交对象，避免发送不必要的数据
                    const dataToSubmit = { ...this.form };
                    // 如果是修改且密码为空，则不提交密码字段
                    if (this.dialog.isEdit && !dataToSubmit.password) {
                        delete dataToSubmit.password;
                    }

                    this.$axios[method](url, dataToSubmit).then(res => {
                        if (res.data.status === 200) {
                            this.$message.success(this.dialog.isEdit ? '修改成功' : '添加成功');
                            this.dialog.visible = false;
                            this.fetchReaderData();
                        } else {
                            this.$message.error(res.data.msg);
                        }
                    }).catch(error => {
                        console.error("Submit error:", error);
                        this.$message.error("操作失败，请检查网络或联系管理员");
                    });
                }
            });
        },
        
        showDeleteDialog(row) {
            this.$confirm(`确定要删除读者“${row.name}”吗？`, '删除确认', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
            }).then(() => {
                this.$axios.delete("/api/admin/readers", { data: { reader_id: row.reader_id } }).then(res => {
                    if (res.data.status === 200) {
                        this.$message.success("删除成功");
                        this.fetchReaderData();
                    } else {
                        this.$message.error(res.data.msg);
                    }
                });
            }).catch(() => {
                // 用户点击取消，无需操作
            });
        }
    }
}
</script>

<style scoped>
.header { text-align: center; font-size: 20px; font-weight: 800; border-bottom: 1px solid #e3e3e3; padding: 20px; }
.body { width: 95%; margin: 20px auto; }
</style>