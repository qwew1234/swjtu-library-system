<template>
    <div>
        <div class="header">
               西南交通大学 - 图书管理系统后台 | 网站作者：李卓嵘
            <el-button type="text" @click="logout" style="float: right; margin-right: 20px;">退出登录</el-button>
        </div>
        <div class="body">
            <div class="liner">
                <!-- <<< 修改: 大幅简化和重命名导航菜单 >>> -->
                <el-menu default-active="1" class="el-menu-vertical-demo" background-color="#545c64" text-color="#fff"
                    active-text-color="#ffd04b" @select="handleMenuSelect">

                    <el-menu-item index="1">
                        <i class="el-icon-collection"></i>
                        <span slot="title">图书管理</span>
                    </el-menu-item>

                    <el-menu-item index="2">
                        <i class="el-icon-user"></i>
                        <span slot="title">读者管理</span>
                    </el-menu-item>

                    <el-menu-item index="3">
                        <i class="el-icon-notebook-2"></i>
                        <span slot="title">借阅记录管理</span>
                    </el-menu-item>

                </el-menu>
            </div>
            <div class="main">
                <!-- <<< 修改: 对应新的子组件 >>> -->
                <div id="book-management" v-show="activeMenu === '1'">
                    <BookManagement />
                </div>

                <div id="reader-management" v-show="activeMenu === '2'">
                    <ReaderManagement />
                </div>

                <div id="record-management" v-show="activeMenu === '3'">
                    <RecordManagement />
                </div>
            </div>
        </div>
    </div>
</template>

<script>
// <<< 修改: 引入新的、重命名后的子组件 >>>
import BookManagement from '@/components/AdminView/BookManagement.vue'
import ReaderManagement from '@/components/AdminView/ReaderManagement.vue' // 暂不实现
import RecordManagement from '@/components/AdminView/RecordManagement.vue'

export default {
    name: 'AdminDashboard', // <<< 修改: 组件名 >>>
    components: {
        BookManagement,
        ReaderManagement,
        RecordManagement
    },
    data() {
        return {
            activeMenu: '1', // <<< 修改: 变量名 >>>
        }
    },
    methods: {
        handleMenuSelect(index) { // <<< 修改: 方法名 >>>
            this.activeMenu = index;
        },
        logout() {
            localStorage.removeItem('token');
            this.$router.push('/login');
            this.$message.success('已成功退出登录');
        }
    },
}
</script>

<style scoped>
/* <<< 样式保持不变，但为main和占位符增加了一些样式 >>> */
.header {
    width: 100%;
    height: 10vh;
    line-height: 10vh;
    font-size: 25px;
    font-weight: 800;
    background-color: #e3e3e3;
    padding-left: 20px;
}

.body {
    width: 100%;
    height: calc(100vh - 10vh);
    display: flex;
    justify-content: space-around;
}

.liner {
    width: 15%;
    height: 100%;
    background-color: #545c64;
}

.main {
    width: 85%;
    padding: 20px;
    overflow-y: auto;
}

.placeholder-text {
    color: #909399;
    font-size: 18px;
    text-align: center;
    margin-top: 50px;
}
</style>