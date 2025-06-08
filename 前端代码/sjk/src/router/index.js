import Vue from 'vue'
import VueRouter from 'vue-router'
// <<< 修改: 引入新的 Login.vue 组件 >>>
import Login from '@/components/Login.vue' 
import UserDashboard from '@/components/MyUser.vue' // 建议重命名为更清晰的名称
import AdminDashboard from '@/components/MyManage.vue' // 建议重命名为更清晰的名称

Vue.use(VueRouter)

export default new VueRouter({
    mode: 'history',
    routes: [
        {
            path: '/',
            redirect: '/login'
        },
        {
            path: '/login',
            // <<< 修改: 指向 Login 组件 >>>
            component: Login, 
            meta: {
                title: "登录"
            },
        },
        {
            path: '/user',
            component: UserDashboard,
            meta: {
                title: "用户界面"
            }
        },
        {
            path: '/manage',
            component: AdminDashboard,
            meta: {
                title: "后台管理界面"
            }
        },
    ]
})