<template>
    <div class="container">
        <div class="login_box">
            <!-- 标题已修改 -->
            <div class="head">
                西南交通大学 图书管理系统
            </div>
            
            <!-- 只保留登录表单 -->
            <div>
                <el-form label-width="0px" class="login_form" :model="loginForm" :rules="loginRules" ref="loginFormRef">
                    <!-- 手机号输入框 -->
                    <el-form-item prop="userortel">
                        <el-input v-model="loginForm.userortel" spellcheck="false" placeholder="请输入绑定的手机号"></el-input>
                    </el-form-item>
                    <!-- 密码输入框 -->
                    <el-form-item prop="password">
                        <el-input v-model="loginForm.password" type="password" spellcheck="false" placeholder="请输入密码" @keyup.enter.native="handleLogin"></el-input>
                    </el-form-item>

                    <!-- 登录按钮 -->
                    <el-form-item class="btns">
                        <el-button type="primary" @click="handleLogin" :loading="loading">登 录</el-button>
                    </el-form-item>
                </el-form>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: 'UserLogin',
    data() {
        // 自定义手机号验证规则
        const validateMobile = (rule, value, callback) => {
            const regMobile = /^(13[0-9]|14[579]|15[0-3,5-9]|16[6]|17[0135678]|18[0-9]|19[89])\d{8}$/;
            if (regMobile.test(value)) {
                return callback();
            }
            callback(new Error('请输入合法的手机号'));
        };

        return {
            loading: false, // 控制登录按钮的加载状态
            loginForm: {
                userortel: '', // 绑定手机号输入
                password: '',  // 绑定密码输入
            },
            loginRules: {
                userortel: [
                    { required: true, message: '请输入手机号', trigger: 'blur' },
                    { validator: validateMobile, trigger: 'blur' }
                ],
                password: [
                    { required: true, message: '请输入密码', trigger: 'blur' }
                ]
            },
        }
    },
    methods: {
        handleLogin() {
            // 登录前先进行表单预验证
            this.$refs.loginFormRef.validate(valid => {
                if (!valid) return;
                // 验证通过，执行登录逻辑
                this.login();
            });
        },
        async login() {
            this.loading = true; // 开始登录，显示加载状态
            
            // 【【【 核心修正点 】】】
            // 将API请求地址从 /api/user/login 修改为 /api/reader/login
            this.$axios.post("/api/reader/login", this.loginForm).then((res) => {
                this.loading = false; // 请求完成，取消加载状态
                if (res.data.code === 200) {
                    this.$message.success('登录成功！');
                    
                    // 将后端返回的token存储到本地浏览器存储中
                    localStorage.setItem("token", res.data.token);

                    // 根据角色(role)跳转到不同页面
                    if (res.data.role === 0) { // 0 代表普通读者
                        this.$router.push('/user');
                    } else { // 1 代表管理员
                        this.$router.push('/manage');
                    }
                } else {
                    this.$message.error(res.data.msg || '登录失败，请检查手机号或密码');
                }
            }).catch((error) => {
                this.loading = false; // 请求失败，也取消加载状态
                console.error("Login request failed:", error);
                this.$message.error("网络故障或服务器错误，请稍后重试");
            });
        },
    }
}
</script>

<style lang="less" scoped>
.container {
    background-color: #2b4b6b;
    height: 100%;
    width: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
}

.head {
    text-align: center;
    padding: 30px 0;
    font-size: 24px;
    font-weight: bold;
    color: #333;
}

.login_box {
    width: 450px;
    height: 320px; /* 调整高度以适应简化的内容 */
    background-color: white;
    border-radius: 5px;
    box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.login_form {
    padding: 0 40px; /* 增加左右内边距 */
    box-sizing: border-box;
}

.el-form-item {
    margin-bottom: 25px; /* 增加表单项之间的间距 */
}

.btns .el-button {
    width: 100%;
    font-size: 16px;
}
</style>