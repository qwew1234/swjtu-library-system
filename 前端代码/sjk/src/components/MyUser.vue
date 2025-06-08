<template>
    <div>
        <!-- <<< 修改: 页面主标题，并加入您的名字 >>> -->
        <div class="header">
               西南交通大学 - 图书管理系统 | 网站作者：李卓嵘 | 读者：{{ currentUserName }}
            <el-button type="text" @click="logout" style="float: right; margin-right: 20px;">退出登录</el-button>
        </div>
        <div class="body">
            <!-- 左侧导航栏 -->
            <div class="liner">
                <!-- <<< 修改: 导航菜单 >>> -->
                <el-menu default-active="1" class="el-menu-vertical-demo" background-color="#545c64" text-color="#fff"
                    active-text-color="#ffd04b" @select="handleMenuSelect">
                    
                    <el-menu-item index="1">
                        <i class="el-icon-search"></i>
                        <span slot="title">图书查询与借阅</span>
                    </el-menu-item>

                    <el-menu-item index="2">
                        <i class="el-icon-collection"></i>
                        <span slot="title">我的借阅</span>
                    </el-menu-item>

                    <el-submenu index="3">
                        <template slot="title">
                            <i class="el-icon-user-solid"></i>
                            <span>个人中心</span>
                        </template>
                        <el-menu-item-group>
                            <!-- <el-menu-item index="6">个人信息</el-menu-item> -->
                            <el-menu-item index="7">修改密码</el-menu-item>
                        </el-menu-item-group>
                    </el-submenu>

                </el-menu>
            </div>
            <div class="main">
                <!-- <<< 修改: 子组件的显示逻辑和命名 >>> -->
                <div id="book-search-view" v-show="activeMenu === '1'">
                    <BookSearchAndBorrow />
                </div>

                <div id="my-borrow-records" v-show="activeMenu === '2'">
                    <MyBorrowRecords :is-active="activeMenu === '2'" />
                </div>

                <!-- <div id="indimsg" v-show="activeMenu === '6'">
                    <indimsg></indimsg>
                </div> -->

                <div id="changepwd" v-show="activeMenu === '7'">
                    <ChangePassword />
                </div>
            </div>
        </div>
    </div>
</template>
<script>
// <<< 核心修改点在这里 >>>
import { jwtDecode } from 'jwt-decode'; // 使用命名导入
import BookSearchAndBorrow from '@/components/ReaderView/BookSearchAndBorrow.vue';
import MyBorrowRecords from '@/components/ReaderView/MyBorrowRecords.vue';
import ChangePassword from '@/components/UserMsg/ChPwd.vue';

export default {
    name: 'UserDashboard', 
    components: {
        BookSearchAndBorrow,
        MyBorrowRecords,
        ChangePassword,
    },
    data() {
        return {
            activeMenu: '1',
            currentUserName: '',
        };
    },
    created() {
        this.decodeToken();
    },
    methods: {
        handleMenuSelect(index) {
            this.activeMenu = index;
        },
        decodeToken() {
            const token = localStorage.getItem('token');
            if (token) {
                try {
                    // <<< 核心修改点在这里 >>>
                    const decoded = jwtDecode(token); // 使用新的函数名
                    this.currentUserName = decoded.data.name; 
                } catch (error) {
                    console.error("Token decode error:", error);
                    this.$router.push('/login');
                }
            } else {
                this.$router.push('/login');
            }
        },
        logout() {
            localStorage.removeItem('token');
            this.$router.push('/login');
            this.$message.success('已成功退出登录');
        }
    },
}
</script>