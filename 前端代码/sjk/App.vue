// ...
methods: {
    // 页面创建时，获取所有图书类别并展示
    fetchBookCategories() {
        this.$axios.get("/api/books/search").then(response => {
            this.bookCategoryList = response.data.tabledata;
        });
    },

    // 点击“借阅”按钮时，获取该书的可借复本列表
    showBorrowDialog(book) {
        this.$axios.get("/api/books/available_instances", { params: { isbn: book.isbn } })
            .then(response => {
                // ... 将返回的实体书号填充到对话框的下拉列表中 ...
            });
    },

    // 在对话框中确认借阅
    handleBorrowConfirm() {
        const selectedBookId = this.borrowDialog.selectedBookId;
        this.$axios.post("/api/borrow/create", { book_id: selectedBookId }).then(() => {
            // ... 提示成功，并刷新图书列表 ...
            this.fetchBookCategories();
        });
    }
}
// ...