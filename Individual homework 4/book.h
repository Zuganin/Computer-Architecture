
#ifndef BOOK_H
#define BOOK_H

#include <vector>

// Класс Book представляет книгу, которая хранится в библиотеке.
// Каждая книга характеризуется рядом, шкафом, номером в шкафу и уникальным названием (идентификатором).
class Book {
public:
    // Конструктор по умолчанию. Создает книгу с неопределенными параметрами.
    Book();

    // Конструктор с параметрами.
    // row    - номер ряда, где находится книга.
    // col    - номер шкафа, где находится книга.
    // number - номер книги в шкафу.
    // name   - идентификатор книги.
    Book(int row, int col, int number, int name);

    // Деструктор по умолчанию.
    ~Book() = default;

    // Генерирет случайным образом книги в библиотеке.
    // M       - количество рядов в библиотеке.
    // N       - количество шкафов в ряду.
    // K       - количество книг в шкафе.
    // library - трехмерный вектор, представляющий библиотеку (ряды, шкафы, книги).
    void generate_books(int M, int N, int K, std::vector<std::vector<std::vector<Book>>>& library);

    // Создает "портфель задач" — список книг.
    // numbers_of_books - общее количество книг, которые нужно создать.
    // Возвращает вектор объектов Book с сгенерированными случайными параметрами.
    static std::vector<Book> generateTaskBackpack(int numbers_of_books);

    // Вводит книги с консоли.
    // Возвращает вектор объектов Book, введенных с консоли.
    // Каждая книга вводится в формате: "ряд шкаф номер название".
    static std::vector<Book> inputBooksFromConsole();

    // Считывает книги из файла.
    // filename - имя файла, из которого нужно считать книги.
    // Возвращает вектор объектов Book, считанных из файла.
    static std::vector<Book> readBooksFromFile(const std::string& filename);

    // Формирует библиотеку в виде трехмерного вектора.
    // books - список книг.
    // Возвращает трехмерный вектор, представляющий шкафы (ряды, шкафы, книги).
    static std::vector<std::vector<std::vector<Book>>> getBooksInCloset(const std::vector<Book> books);

    // Выводит текущую структуру библиотеки в консоль.
    // books - структура библиотеки в виде трехмерного вектора.
    static void printLibrary(const std::vector<std::vector<std::vector<Book>>> books);

    std::string getBookInfo() const;

    // Оператор сравнения книг.
    // Используется для сортировки книг по названию (идентификатору).
    bool operator<(const Book& other) const;


private:
    int row_;    // Номер ряда, где находится книга.
    int col_;    // Номер шкафа в ряду.
    int number_; // Номер книги в шкафу.
    int name_;   // Название (идентификатор) книги.
};

#endif //BOOK_H

