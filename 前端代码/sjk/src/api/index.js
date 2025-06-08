import axios from 'axios'
import router from '@/router' // 引入路由是为了在token失效时进行跳转
import { Message } from 'element-ui'; // 引入ElementUI的消息提示

// 创建一个 Axios 实例
const instance = axios.create({
    baseURL: 'http://127.0.0.1:5000', // 你的后端地址
    timeout: 5000 // 请求超时时间
});

// --- 【核心修改】添加请求拦截器 ---
instance.interceptors.request.use(
    config => {
        // 在发送请求之前做些什么
        // 1. 从本地存储中获取token
        const token = localStorage.getItem('token');
        
        // 2. 如果token存在，则为每个请求头添加token
        if (token) {
            config.headers['Authorization'] = 'Bearer ' + token; // 约定俗成的 Bearer 方案
            // 同时，我们把 token 也放在一个自定义的 'token' 头里，以兼容您原来的后端逻辑
            config.headers['token'] = token; 
        }
        return config;
    },
    error => {
        // 对请求错误做些什么
        console.log(error); 
        return Promise.reject(error);
    }
);

// --- (可选，但推荐) 添加响应拦截器 ---
instance.interceptors.response.use(
    response => {
        // 对响应数据做点什么
        // 如果后端有特定的成功或失败代码，可以在这里统一处理
        return response;
    },
    error => {
        // 对响应错误做点什么
        if (error.response) {
            switch (error.response.status) {
                // 401: Unauthorized - 通常是token过期或无效
                case 401:
                    Message.error('身份认证失败，请重新登录');
                    localStorage.removeItem('token'); // 清除无效的token
                    router.push('/login');
                    break;
                // 其他错误状态码处理
                default:
                    Message.error(error.response.data.msg || '服务器响应错误');
            }
        }
        return Promise.reject(error);
    }
);

export default instance;