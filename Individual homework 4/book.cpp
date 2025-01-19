#include <iostream>

#include "book.h"
#include <random>
#include <sstream>
#include <fstream>

std::mt19937 rnd(52);
// Конструктор по умолчанию
Book::Book() : row_(0), col_(0), number_(0), name_(0) {}

// Конструктор с параметрами
Book::Book(int row, int col, int number, int name) : row_(row), col_(col), number_(number), name_(name) {}

// // Генерация случайных данных
// void Book::generate_books(int M, int N, int K, std::vector<std::vector<std::vector<Book>>>& library) {
//     for (int i = 0; i < M; ++i) {
//         for (int j = 0; j < N; ++j) {
//             for (int k = 0; k < K; ++k) {
//                 int name = rnd() % 1000; // Генерация случайного идентификатора
//                 library[i][j][k] = { i, j, k,name};
//             }
//         }
//     }
// }

// Генерация портфеля задач (список книг)
std::vector<Book> Book::generateTaskBackpack(int numbers_of_books) {
    std::vector<Book> books;
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> row_dist(0, 52);   // Ряды от 0 до 52
    std::uniform_int_distribution<> col_dist(0, 52);   // Шкафы от 0 до 52
    std::uniform_int_distribution<> num_dist(0, 15);  // Книги в шкафу от 0 до 15
    std::uniform_int_distribution<> name_dist(0, 43264); // Идентификаторы книг

    // Заполняем портфель задач, те книги, которые нужно найти.
    for (int i = 0; i < numbers_of_books; ++i) {
        books.emplace_back(row_dist(gen), col_dist(gen), num_dist(gen), name_dist(gen));
    }
    return books;
}


// Функция для ввода книг с консоли
std::vector<Book> Book::inputBooksFromConsole() {
    int num_books;
    std::cout << "Введите количество книг: ";
    std::cin >> num_books; // Ввод количества книг
    std::cout << "Введите данные для книги: " << std::endl;

    std::vector<Book> books; // Локальный вектор для хранения книг
    for (int i = 0; i < num_books; ++i) {
        int row, col, number, name;
        if(row < 0 || col < 0 || number < 0 ){
            throw std::runtime_error("Ошибка: Некорректные данные, введите положительные числа.");
        }
        std::cin >> row >> col >> number >> name;
        books.push_back({row, col, number, name}); // Добавление книги в вектор
    }

    return books; // Возвращаем введенный список книг
}

// Функция для чтения книг из файла
std::vector<Book> Book::readBooksFromFile(const std::string& filename) {
    std::ifstream file(filename); // Открываем файл для чтения

    if (!file.is_open()) {
        throw std::runtime_error("Не удалось открыть файл: " + filename); // Ошибка, если файл не открыт
    }

    std::vector<Book> books; // Локальный вектор для хранения книг
    int row, col, number, name;

    // Чтение данных из файла построчно
    while (file >> row >> col >> number >> name) {
        if(row < 0 || col < 0 || number < 0 ){
            throw std::runtime_error("Ошибка: Некорректные данные в файле.");
        }
        Book book = {row, col, number, name};
        books.emplace_back(book); // Добавление книги в вектор
    }
    return books; // Возвращаем список книг, прочитанных из файла
}



// Формирование структуры библиотеки (шкафы с книгами)
std::vector<std::vector<std::vector<Book>>> Book::getBooksInCloset(const std::vector<Book> books) {
    // Создаем трехмерный вектор для хранения книг в библиотеке c запасом по памяти
    std::vector<std::vector<std::vector<Book>>> library(100, std::vector<std::vector<Book>>(100));

    // Формируем структуру библиотеки для вывода
    for (const auto& book : books) {
        library[book.row_][book.col_].push_back(book);
    }

    return library;
}

// Печать структуры библиотеки
void Book::printLibrary(const std::vector<std::vector<std::vector<Book>>> books) {
    for (size_t row = 0; row < books.size(); ++row) {
        for (size_t col = 0; col < books[row].size(); ++col) {
            for (const auto& book : books[row][col]) {
                std::cout << "Ряд " << row+1  << ", Шкаф " << col+1
                          << ", Порядок книги в шкафу " << book.number_ + 1 << " (Название: " << book.name_ << ")" << std::endl;
            }
        }
    }
}

// Получение информации о книге
std::string Book::getBookInfo() const {
    std::ostringstream info;
    info << "'" << name_ << "'" << " (Ряд " << row_+1 << ", Шкаф " << col_+1 << ", Позиция " << number_+1 << ")";
    return info.str();
}

// Оператор сравнения для сортировки
bool Book::operator<(const Book& other) const {
    return name_ < other.name_;
}
