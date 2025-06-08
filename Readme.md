# 西南交通大学 - 图书管理系统 (数据库课程设计)

![Python](https://img.shields.io/badge/Python-3.8+-blue.svg) ![Flask](https://img.shields.io/badge/Flask-2.x-green.svg) ![Vue.js](https://img.shields.io/badge/Vue.js-2.x-brightgreen.svg) ![MySQL](https://img.shields.io/badge/MySQL-8.0-orange.svg) ![Element UI](https://img.shields.io/badge/Element_UI-2.15-blue.svg)

这是一个基于 Vue.js 和 Flask 构建的前后端分离的图书管理系统，旨在作为西南交通大学《数据库原理与设计》课程的最终项目。系统深度应用了数据库规范化设计、触发器、视图等核心技术，实现了完整的用户认证、图书借阅闭环以及多权限后台管理功能。

**作者：李卓嵘**

---

## 1. 项目背景与目标

为应对高校日益增长的图书流通量和师生对信息化服务的高要求，传统图书馆管理模式在效率和用户体验上面临瓶颈。本项目旨在设计并实现一个功能完善、界面友好的现代化Web图书管理系统，将图书管理的核心业务流程进行信息化、自动化改造，从而提升图书馆的服务水平和管理效率。

---

## 2. 功能模块与演示

系统主要分为 **读者端** 和 **管理员端** 两大功能模块。

### 2.1 读者端核心功能

*   **用户认证**：提供安全的登录接口，通过JWT进行会话管理。
*   **图书查询**：支持查看全馆所有图书类别信息，实时显示可借阅数量。
*   **在线借阅**：实现了规范的“两步借阅”流程，用户先选择书种（ISBN），再从可用的实体书复本中选择一本进行借阅。
*   **借阅管理**：用户可随时查看自己的当前借阅、历史借阅记录以及每本书的应还日期。
*   **在线归还**：用户可对“借阅中”的图书执行归还操作。
*   **个人中心**：支持用户修改自己的登录密码。

#### **运行截图**
| 查询与借阅 | 选择复本 | 我的借阅记录 |
| :---: | :---: | :---: |
| ![读者段借阅与查询](https://github.com/user-attachments/assets/3a78f3c5-6e6b-46e5-91ce-dcb63ebf32f9) | ![读者段选择副本](https://github.com/user-attachments/assets/9fe3b69d-4e94-4bf2-aa2f-96bc7099ee43) | ![读者段借阅记录](https://github.com/user-attachments/assets/291a4871-d529-4d7b-acaa-8b19b1d93157) |

### 2.2 管理员端核心功能

*   **权限控制**：所有管理员接口均设有权限校验，确保只有管理员角色的用户才能访问。
*   **图书类别管理 (ISBN)**：对图书的通用信息（书名、作者、出版社等）进行完整的增、删、改、查（CRUD）操作。
*   **实体书复本管理**：支持对指定ISBN的图书进行“入库”（添加新复本）和“注销”（删除在馆复本）操作，实现对物理库存的精确管理。
*   **读者管理**：支持对系统内的所有读者和管理员账户进行增、删、改、查操作。
*   **全馆借阅监控**：可查看所有用户的借阅流水记录，掌握全馆图书的流通状态。

#### **运行截图**
| 图书类别管理 | 复本入库管理 | 读者管理 |
| :---: | :---: | :---: |
| ![图书类别管理](https://github.com/user-attachments/assets/e1473984-27b7-429a-b1e5-84f135b38997) | ![复本入库管理](https://github.com/user-attachments/assets/7132fd45-7499-43a6-aefd-712144df9d6e) | ![读者管理](https://github.com/user-attachments/assets/e61d7592-5392-405f-9cac-7ce51c1dba8b) |

---

## 3. 技术架构与核心设计

### 3.1 技术栈

*   **前端**: Vue.js 2 + Element UI + Vue Router + Axios
*   **后端**: Flask + SQLAlchemy + PyMySQL
*   **数据库**: MySQL 8.0
*   **认证方案**: JWT (JSON Web Token)

### 3.2 数据库设计亮点

本项目数据库设计严格遵循第三范式（3NF），通过关系模型精确地映射了真实世界的业务逻辑。

*   **核心表结构**:
    1.  `readers`: 读者信息表
    2.  `book_category`: 图书类别信息表 (ISBN维度)
    3.  `book_instance`: 实体书信息表 (复本维度)
    4.  `borrow_records`: 借阅记录表
*   **设计巧思**:
    *   **触发器自动化**: 通过设计 `after_borrow_pro` 和 `after_return_pro` 两个触发器，将图书借还时涉及的 **3** 张表（`book_instance`, `book_category`, `readers`）的数量和状态更新逻辑**下沉至数据库层面**。这保证了无论通过何种方式操作数据，其一致性和原子性都得到了强有力的保障，极大地降低了应用层的代码复杂度和出错风险。
    *   **视图简化查询**: 创建了 `overdue_records` 视图，将复杂的多表连接查询封装成一个虚拟表。应用层只需执行 `SELECT * FROM overdue_records` 即可快速获取所有逾期信息，实现了业务逻辑的解耦。

---

## 4. 项目本地部署指南

### 4.1 环境准备
请确保您的电脑已安装以下软件及环境：
*   **Node.js**: `v16.0.0` 或更高版本
*   **Python**: `v3.8.0` 或更高版本
*   **MySQL**: `v8.0`

### 4.2 数据库初始化
1.  启动您的本地 MySQL 服务。
2.  使用 Navicat, MySQL Workbench 或其他数据库客户端，创建一个新的数据库，字符集请选择 `utf8mb4`，数据库名称为 `swjtu_library`。
3.  在该数据库中，执行项目根目录下的 `swjtu_library_pro.sql` 文件。这将创建所有必需的表、视图、触发器，并导入初始的示例数据。

<!-- README.md -->

## 4.3 后端启动流程

1. **进入后端代码目录**
   ```bash
   cd 后端代码
   ```

2. **（推荐）创建并激活 Python 虚拟环境**
   
   - **Windows**：
     ```bash
     python -m venv venv
     venv\Scripts\activate
     ```
   
   - **macOS / Linux**：
     ```bash
     python3 -m venv venv
     source venv/bin/activate
     ```

3. **安装所有 Python 依赖库**
   ```bash
   pip install -r requirements.txt
   ```

4. **配置数据库连接**
   
   打开 `config.py` 文件，找到 `SQLALCHEMY_DATABASE_URI` 变量，并将其中的用户名和密码修改为您自己的 MySQL 配置。
   
   例如：
   ```
   'mysql+pymysql://your_user:your_password@127.0.0.1:3306/swjtu_library'
   ```

5. **启动后端服务**
   ```bash
   python app.py
   ```
   当命令行输出 `* Running on http://127.0.0.1:5000` 时，表示后端已成功启动。请保持此窗口运行。

---

## 4.4 前端启动流程

1. **打开一个新的命令行窗口，进入前端代码目录**
   ```bash
   cd 前端代码/sjk
   ```

2. **安装所有 Node.js 依赖（首次运行或依赖更新后需要）**
   ```bash
   npm install
   ```

3. **启动前端开发服务器**
   ```bash
   npm run serve
   ```
   编译完成后，在浏览器中打开命令行提示的本地地址（通常是 `http://localhost:8080`）即可访问本系统。

---

## 5. 初始登录账号

- **管理员**  
  手机号：`13888888888`  
  密码：`admin`

- **普通读者（张伟）**  
  手机号：`13811110001`  
  密码：`123456`
