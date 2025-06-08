# --- Pro Version: Refactored for standard library management ---

from flask import Flask, jsonify, request
from sqlalchemy import text, exc
from config import BaseConfig
from flask_sqlalchemy import SQLAlchemy
import auth
import datetime
from redis import StrictRedis
from flask_cors import CORS

# --- Basic Setup (No changes needed) ---
app = Flask(__name__)
app.config.from_object(BaseConfig)
db = SQLAlchemy(app)
CORS(app, supports_credentials=True)
redis_store = StrictRedis(host=BaseConfig.REDIS_HOST, port=BaseConfig.REDIS_PORT, decode_responses=True)

# --- Database Connection Check ---
with app.app_context():
    with db.engine.connect() as conn:
        rs = conn.execute(text("select 1"))
        print("--- Database connection successful (Pro Version) ---")
        print(rs.fetchone())


# --- Helper Function ---
def get_reader_info_from_token(token):
    return auth.decode_func(token)


# --- Reader Authentication Module ---
@app.route("/api/reader/login", methods=["POST"])
def reader_login():
    """读者或管理员登录接口 (No changes from previous version)"""
    telephone = request.json.get("userortel").strip()
    password = request.json.get("password").strip()
    sql = text('select * from readers where telephone = :tel and password = :pwd')
    data = db.session.execute(sql, {'tel': telephone, 'pwd': password}).first()
    if data:
        reader_info = {'reader_id': data[0], 'name': data[1], 'telephone': data[3]}
        token = auth.encode_func(reader_info)
        return jsonify({"code": 200, "msg": "登录成功", "token": token, "role": data[12]})
    else:
        return jsonify({"code": 1000, "msg": "手机号或密码错误"})


# --- Book Search & Borrow Module (For Readers) ---

@app.route("/api/books/search", methods=["GET"])
def search_books():
    """
    获取所有图书类别信息，用于展示。
    This replaces the old get_all_books.
    """
    sql = text('SELECT * FROM book_category')
    data = db.session.execute(sql).fetchall()
    book_list = [{
        'isbn': row[0],
        'book_name': row[1],
        'category': row[2],
        'author': row[3],
        'publisher': row[4],
        'publish_date': row[5].strftime('%Y-%m-%d') if row[5] else '',
        'price': float(row[6]) if row[6] else 0.0,
        'intro': row[7],
        'total_quantity': row[8],
        'borrowable_quantity': row[9]
    } for row in data]
    return jsonify(status=200, tabledata=book_list)


@app.route("/api/books/available_instances", methods=["GET"])
def get_available_instances():
    """根据ISBN获取可借阅的实体书列表"""
    isbn = request.args.get('isbn')
    if not isbn:
        return jsonify(status=400, msg="缺少ISBN参数")

    sql = text('SELECT book_id FROM book_instance WHERE isbn = :isbn AND is_borrowed = 0')
    data = db.session.execute(sql, {'isbn': isbn}).fetchall()
    instances = [row[0] for row in data]

    return jsonify(status=200, instances=instances)


@app.route("/api/borrow/create", methods=["POST"])
def borrow_book():
    """读者选择一本实体书进行借阅"""
    try:
        reader_info = get_reader_info_from_token(request.headers.get('token'))
        reader_id = reader_info['reader_id']
    except Exception:
        return jsonify(status=401, msg="Token无效或已过期，请重新登录")

    book_id = request.json.get("book_id")  # 注意：现在借阅的是 book_id，而不是 isbn
    if not book_id:
        return jsonify(status=400, msg="请求参数错误，缺少 book_id")

    try:
        # 检查读者是否超过最大借阅量
        reader_sql = text("SELECT borrowed_quantity, max_borrow_quantity FROM readers WHERE reader_id = :id")
        reader_data = db.session.execute(reader_sql, {'id': reader_id}).first()
        if reader_data and reader_data[0] >= reader_data[1]:
            return jsonify(status=1001, msg="已达到最大借阅数量，无法借阅更多图书")

        # 检查该书是否可借
        instance_sql = text("SELECT is_borrowed FROM book_instance WHERE book_id = :id")
        instance_data = db.session.execute(instance_sql, {'id': book_id}).first()
        if not instance_data or instance_data[0] == 1:
            return jsonify(status=1002, msg="该书已被借出或不存在")

        # 执行借阅
        borrow_date = datetime.datetime.now()
        due_date = borrow_date + datetime.timedelta(days=30)  # 假设借期30天

        insert_sql = text(
            'INSERT INTO borrow_records(book_id, reader_id, borrow_date, due_date) VALUES (:b_id, :r_id, :b_date, :d_date)')
        db.session.execute(insert_sql, {
            'b_id': book_id,
            'r_id': reader_id,
            'b_date': borrow_date.strftime('%Y-%m-%d %H:%M:%S'),
            'd_date': due_date.strftime('%Y-%m-%d %H:%M:%S')
        })
        db.session.commit()  # 触发器将在此处执行
        return jsonify(status=200, msg="借阅成功！")

    except exc.SQLAlchemyError as e:
        db.session.rollback()
        print(e)
        return jsonify(status=500, msg="数据库操作失败")


@app.route("/api/borrow/my_records", methods=["GET"])
def get_my_records():
    """获取当前用户的借阅记录"""
    try:
        reader_info = get_reader_info_from_token(request.headers.get('token'))
        reader_id = reader_info['reader_id']
    except Exception:
        return jsonify(status=401, tabledata=[])

    sql = text("""
        SELECT br.record_id, bc.book_name, bc.author, br.borrow_date, br.due_date, br.return_date
        FROM borrow_records br
        JOIN book_instance bi ON br.book_id = bi.book_id
        JOIN book_category bc ON bi.isbn = bc.isbn
        WHERE br.reader_id = :reader_id
        ORDER BY br.borrow_date DESC
    """)
    data = db.session.execute(sql, {'reader_id': reader_id}).fetchall()
    records = [{
        'record_id': row[0],
        'book_name': row[1],
        'author': row[2],
        'borrow_date': row[3].strftime('%Y-%m-%d'),
        'due_date': row[4].strftime('%Y-%m-%d'),
        'status': '已归还' if row[5] else '借阅中'
    } for row in data]
    return jsonify(status=200, tabledata=records)


@app.route("/api/borrow/return", methods=["POST"])
def return_book():
    """归还一本书"""
    try:
        reader_info = get_reader_info_from_token(request.headers.get('token'))
        if not reader_info: return jsonify(status=401, msg="用户认证失败")
    except Exception:
        return jsonify(status=401, msg="Token解析失败")

    record_id = request.json.get("record_id")
    if not record_id: return jsonify(status=400, msg="缺少record_id")

    try:
        record_sql = text('SELECT * FROM borrow_records WHERE record_id = :id AND return_date IS NULL')
        record = db.session.execute(record_sql, {'id': record_id}).first()

        if not record: return jsonify(status=404, msg="找不到该借阅记录或该书已归还")

        return_date = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        update_sql = text('UPDATE borrow_records SET return_date = :ret_date WHERE record_id = :id')
        db.session.execute(update_sql, {'ret_date': return_date, 'id': record_id})

        db.session.commit()
        return jsonify(status=200, msg="归还成功！")
    except exc.SQLAlchemyError as e:
        db.session.rollback()
        print(e)
        return jsonify(status=500, msg="数据库操作失败")


# --- Administrator Modules (Pro Version) ---

def check_admin_role(token):
    """辅助函数：检查Token是否为管理员角色"""
    try:
        info = get_reader_info_from_token(token)
        sql = text("SELECT role FROM readers WHERE reader_id = :id")
        user = db.session.execute(sql, {'id': info['reader_id']}).first()
        return user and user[0] == 1
    except Exception:
        return False


@app.route("/api/admin/book_category", methods=["POST", "PUT", "DELETE"])
def manage_book_category():
    """管理员：增、删、改图书类别信息"""
    if not check_admin_role(request.headers.get('token')):
        return jsonify(status=403, msg="权限不足")

    try:
        if request.method == 'POST':  # 添加
            data = request.json

            # <<< 核心修正：对 total_quantity 和 price 做更安全的数据处理 >>>
            try:
                # 尝试将数量和价格转为数字，如果失败则使用默认值0
                total_qty = int(data.get('total_quantity') or 0)
                price_val = float(data.get('price') or 0.0)
            except (ValueError, TypeError):
                total_qty = 0
                price_val = 0.0

            sql = text("""
                INSERT INTO book_category (isbn, book_name, category, author, publisher, publish_date, price, intro, total_quantity, borrowable_quantity) 
                VALUES (:isbn, :book_name, :category, :author, :publisher, :publish_date, :price, :intro, :total, :borrowable)
            """)
            db.session.execute(sql, {
                'isbn': data.get('isbn'), 'book_name': data.get('book_name'), 'category': data.get('category'),
                'author': data.get('author'), 'publisher': data.get('publisher'),
                'publish_date': data.get('publish_date'),
                'price': price_val,
                'intro': data.get('intro'),
                'total': total_qty,
                'borrowable': total_qty  # 新增书种时，可借阅数 = 总数
            })
            db.session.commit()
            return jsonify(status=200, msg="添加书种成功")

        # 在 /api/admin/book_category 接口中，找到 if request.method == 'PUT': 部分
        if request.method == 'PUT':  # 修改
            data = request.json

            # <<< 核心修改：加入更新数量的逻辑 >>>
            try:
                new_total = int(data.get('total_quantity'))

                # 1. 获取当前已借出数量
                check_sql = text("SELECT COUNT(*) FROM book_instance WHERE isbn = :isbn AND is_borrowed = 1")
                borrowed_count = db.session.execute(check_sql, {'isbn': data.get('isbn')}).scalar()

                if new_total < borrowed_count:
                    return jsonify(status=400, msg=f"修改失败：总数不能小于已借出的 {borrowed_count} 本")

                # 2. 计算新的可借阅数量
                new_borrowable = new_total - borrowed_count

                # 3. 更新 book_category 表
                sql = text("""
                    UPDATE book_category SET 
                    book_name=:book_name, category=:category, author=:author, publisher=:publisher, 
                    publish_date=:publish_date, price=:price, intro=:intro, 
                    total_quantity=:total, borrowable_quantity=:borrowable 
                    WHERE isbn=:isbn
                """)
                db.session.execute(sql, {
                    'book_name': data.get('book_name'), 'category': data.get('category'), 'author': data.get('author'),
                    'publisher': data.get('publisher'), 'publish_date': data.get('publish_date'),
                    'price': float(data.get('price') or 0.0), 'intro': data.get('intro'),
                    'total': new_total, 'borrowable': new_borrowable, 'isbn': data.get('isbn')
                })

                # 这一步是简化的处理，实际项目中会更复杂地处理实体书的增删
                # 这里我们假设总数变化时，实体书也相应调整（这是一个简化逻辑）

                db.session.commit()
                return jsonify(status=200, msg="修改信息成功")
            except Exception as e:
                db.session.rollback()
                print(e)
                return jsonify(status=500, msg="修改失败，请检查数据格式")
        # ... (DELETE 部分不变) ...
        if request.method == 'DELETE':
            isbn = request.json.get('isbn')
            check_sql = text("SELECT COUNT(*) FROM book_instance WHERE isbn = :isbn AND is_borrowed = 1")
            borrowed_count = db.session.execute(check_sql, {'isbn': isbn}).scalar()
            if borrowed_count > 0:
                return jsonify(status=400, msg="删除失败：该书仍有复本未归还")

            sql = text("DELETE FROM book_category WHERE isbn = :isbn")
            db.session.execute(sql, {'isbn': isbn})
            db.session.commit()
            return jsonify(status=200, msg="删除书种成功")

    except exc.IntegrityError:
        db.session.rollback()
        return jsonify(status=500, msg="操作失败：ISBN可能已存在或数据格式错误")
    except Exception as e:
        db.session.rollback()
        print(e)
        return jsonify(status=500, msg="服务器内部错误")

@app.route("/api/admin/all_records", methods=["GET"])
def get_all_borrow_records_admin():
    """管理员：查看所有借阅记录"""
    if not check_admin_role(request.headers.get('token')):
        return jsonify(status=403, msg="权限不足")

    try:
        sql = text("""
            SELECT 
                br.record_id, 
                bc.book_name, 
                r.name as reader_name, 
                br.borrow_date, 
                br.due_date, 
                br.return_date
            FROM borrow_records br
            JOIN book_instance bi ON br.book_id = bi.book_id
            JOIN book_category bc ON bi.isbn = bc.isbn
            JOIN readers r ON br.reader_id = r.reader_id
            ORDER BY br.borrow_date DESC
        """)

        data = db.session.execute(sql).fetchall()

        records = [{
            'record_id': row[0],
            'book_name': row[1],
            'reader_name': row[2],
            'borrow_date': row[3].strftime('%Y-%m-%d %H:%M:%S'),
            'due_date': row[4].strftime('%Y-%m-%d'),
            'status': '已归还' if row[5] else '借阅中'
        } for row in data]

        return jsonify(status=200, tabledata=records)

    except Exception as e:
        print(e)
        return jsonify(status=500, msg="数据库查询失败")


@app.route("/api/admin/borrowed_count", methods=["GET"])
def get_borrowed_count():
    if not check_admin_role(request.headers.get('token')):
        return jsonify(status=403, msg="权限不足")

    isbn = request.args.get('isbn')
    sql = text("SELECT COUNT(*) FROM book_instance WHERE isbn = :isbn AND is_borrowed = 1")
    count = db.session.execute(sql, {'isbn': isbn}).scalar()
    return jsonify(status=200, count=count)


# --- 【新增】Reader Management Module ---
@app.route("/api/admin/readers", methods=["GET", "POST", "PUT", "DELETE"])
def manage_readers():
    """管理员：增、删、改、查读者信息"""
    if not check_admin_role(request.headers.get('token')):
        return jsonify(status=403, msg="权限不足")

    try:
        if request.method == 'GET':
            sql = text(
                "SELECT reader_id, name, department, telephone, role, max_borrow_quantity, borrowed_quantity FROM readers")
            data = db.session.execute(sql).fetchall()
            reader_list = [{
                'reader_id': row[0], 'name': row[1], 'department': row[2], 'telephone': row[3],
                'role': row[4], 'max_borrow_quantity': row[5], 'borrowed_quantity': row[6]
            } for row in data]
            return jsonify(status=200, tabledata=reader_list)

        if request.method == 'POST':  # 添加新读者
            data = request.json

            # <<< 核心修正：确保密码字段总有一个有效值 >>>
            # 如果前端传来的密码非空，就用它；否则，坚决使用 '123456' 作为默认密码。
            password_to_set = data.get('password') if data.get('password') else '123456'

            sql = text("""
                INSERT INTO readers (reader_id, name, password, department, telephone, role, max_borrow_quantity) 
                VALUES (:reader_id, :name, :password, :department, :telephone, :role, :max_borrow)
            """)
            db.session.execute(sql, {
                'reader_id': data.get('reader_id'),
                'name': data.get('name'),
                'password': password_to_set,  # <-- 使用修正后的密码
                'department': data.get('department'),
                'telephone': data.get('telephone'),
                'role': int(data.get('role', 0)),
                'max_borrow': int(data.get('max_borrow_quantity', 5))
            })
            db.session.commit()
            return jsonify(status=200, msg="添加读者成功")

        if request.method == 'PUT':  # 修改读者信息
            data = request.json
            sql = text("""
                UPDATE readers SET name=:name, department=:department, telephone=:telephone, 
                role=:role, max_borrow_quantity=:max_borrow
                WHERE reader_id=:reader_id
            """)
            db.session.execute(sql, {
                'name': data.get('name'), 'department': data.get('department'), 'telephone': data.get('telephone'),
                'role': int(data.get('role', 0)), 'max_borrow': int(data.get('max_borrow_quantity', 5)),
                'reader_id': data.get('reader_id')
            })
            # 如果也传了新密码，就额外更新密码
            if data.get('password'):
                pwd_sql = text("UPDATE readers SET password=:pwd WHERE reader_id=:id")
                db.session.execute(pwd_sql, {'pwd': data.get('password'), 'id': data.get('reader_id')})

            db.session.commit()
            return jsonify(status=200, msg="修改读者信息成功")

        if request.method == 'DELETE':  # 删除读者
            reader_id = request.json.get('reader_id')
            # 删除前检查该读者是否还有未归还的图书
            check_sql = text("SELECT borrowed_quantity FROM readers WHERE reader_id = :id")
            borrowed_qty = db.session.execute(check_sql, {'id': reader_id}).scalar()
            if borrowed_qty > 0:
                return jsonify(status=400, msg=f"删除失败：该读者尚有 {borrowed_qty} 本书未归还")

            # 安全删除 (注意：实际应用中可能需要先删除其他关联表中的记录，但我们的外键已设置级联删除)
            sql = text("DELETE FROM readers WHERE reader_id = :id")
            db.session.execute(sql, {'id': reader_id})
            db.session.commit()
            return jsonify(status=200, msg="删除读者成功")

    except exc.IntegrityError as e:  # 捕获主键或唯一索引冲突
        db.session.rollback()
        print(e)
        return jsonify(status=500, msg="操作失败：读者证号或手机号可能已存在")
    except Exception as e:
        db.session.rollback()
        print(e)
        return jsonify(status=500, msg="服务器内部错误")


# --- 【新增】Book Instance (Copy) Management Module ---
@app.route("/api/admin/instances", methods=["GET", "POST", "DELETE"])
def manage_book_instances():
    """管理员：获取、添加、删除指定ISBN的实体书复本"""
    if not check_admin_role(request.headers.get('token')):
        return jsonify(status=403, msg="权限不足")

    try:
        if request.method == 'GET':
            isbn = request.args.get('isbn')
            if not isbn: return jsonify(status=400, msg="缺少ISBN参数")

            sql = text("SELECT book_id, is_borrowed FROM book_instance WHERE isbn = :isbn")
            data = db.session.execute(sql, {'isbn': isbn}).fetchall()
            instances = [{'book_id': row[0], 'status': '已借出' if row[1] else '在馆可借'} for row in data]
            return jsonify(status=200, instances=instances)

        if request.method == 'POST':  # 入库新复本
            data = request.json
            isbn = data.get('isbn')
            book_id = data.get('book_id')
            if not all([isbn, book_id]):
                return jsonify(status=400, msg="缺少ISBN或书号")

            insert_sql = text("INSERT INTO book_instance (book_id, isbn, is_borrowed) VALUES (:book_id, :isbn, 0)")
            db.session.execute(insert_sql, {'book_id': book_id, 'isbn': isbn})

            # 更新 category 表的数量
            update_sql = text(
                "UPDATE book_category SET total_quantity = total_quantity + 1, borrowable_quantity = borrowable_quantity + 1 WHERE isbn = :isbn")
            db.session.execute(update_sql, {'isbn': isbn})

            db.session.commit()
            return jsonify(status=200, msg="复本入库成功")

        if request.method == 'DELETE':  # 删除/报废复本
            book_id = request.json.get('book_id')
            if not book_id: return jsonify(status=400, msg="缺少书号")

            # 删除前检查该实体书是否已被借出
            instance = db.session.execute(text("SELECT isbn, is_borrowed FROM book_instance WHERE book_id = :id"),
                                          {'id': book_id}).first()
            if not instance: return jsonify(status=404, msg="找不到该实体书")
            if instance.is_borrowed: return jsonify(status=400, msg="删除失败：该书正在被借阅中，无法删除")

            # 更新 category 表的数量
            update_sql = text(
                "UPDATE book_category SET total_quantity = total_quantity - 1, borrowable_quantity = borrowable_quantity - 1 WHERE isbn = :isbn")
            db.session.execute(update_sql, {'isbn': instance.isbn})

            # 删除实体书
            delete_sql = text("DELETE FROM book_instance WHERE book_id = :id")
            db.session.execute(delete_sql, {'id': book_id})

            db.session.commit()
            return jsonify(status=200, msg="复本删除成功")

    except exc.IntegrityError:
        db.session.rollback()
        return jsonify(status=500, msg="操作失败：该书号可能已存在")
    except Exception as e:
        db.session.rollback()
        print(e)
        return jsonify(status=500, msg="服务器内部错误")
if __name__ == '__main__':
    app.run(debug=True, host='127.0.0.1', port='5000')