#include <algorithm>
#include <fstream>
#include <iostream>
#include <omp.h>
#include <queue>
#include <vector>

#include "book.cpp"

std::queue<Book> task_queue;  // Очередь задач (каждая задача - это книга)
std::vector<Book> catalog;    // Каталог книг, куда добавляются обработанные задачи
bool all_tasks_added = false; // Флаг для завершения потоков

// Мьютексы для OpenMP
omp_lock_t task_lock;
omp_lock_t catalog_lock;

void processTask(int thread_id) {
    while (true) {
        Book task;
        bool has_task = false;

        // Захват задачи из очереди
        omp_set_lock(&task_lock);
        if (!task_queue.empty()) {
            task = task_queue.front();
            task_queue.pop();
            has_task = true;
        }
        omp_unset_lock(&task_lock);

        // Если задачи нет, проверяем, завершены ли все задачи
        if (!has_task) {
            if (all_tasks_added) break;
            continue;
        }

        // Обработка задачи: добавление книги в каталог
        omp_set_lock(&catalog_lock);
        catalog.push_back(task);
        omp_unset_lock(&catalog_lock);

        // Вывод информации о выполнении задачи
        #pragma omp critical
        {
            std::cout << "Студент " << thread_id << " успешно добавил книгу "
                      << task.getBookInfo() << " в каталог" << std::endl;
        }
    }
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Ошибка: Не указан режим работы. Используйте --generate, --console или --file <filename>.\n";
        return 1;
    }

    std::vector<Book> books; // Вектор для хранения исходных данных о книгах
    try {
        // Генерация случайных данных
        if (strcmp(argv[1], "-generate") == 0) {
            int num_books = 52; // По умолчанию генерируется 52 книги
            if (argc == 3) {
                num_books = std::stoi(argv[2]); // Количество книг можно передать как аргумент
            }

            books = Book::generateTaskBackpack(num_books); // Генерация книг
        }
        // Ввод данных с консоли
        else if (strcmp(argv[1], "-console") == 0) {
            books = Book::inputBooksFromConsole(); // Ввод книг с консоли
        }
        // Чтение данных из файла
        else if (strcmp(argv[1], "-file") == 0) {
            if (argc < 3) {
                throw std::runtime_error("Ошибка: Укажите имя файла после флага -file.");
            }

            books = Book::readBooksFromFile(argv[2]); // Чтение книг из указанного файла
        } else {
            throw std::runtime_error("Ошибка: Неизвестный флаг. Используйте -generate <numbers of book>, -console или -file <file name>.");
        }

        // Формирование структуры библиотеки
        auto library = Book::getBooksInCloset(books);
        std::cout << "Начальное состояние библиотеки:" << std::endl;
        Book::printLibrary(library);

        // Инициализация OpenMP мьютексов
        omp_init_lock(&task_lock);
        omp_init_lock(&catalog_lock);

        // Заполнение очереди задач
        for (const auto& book : books) {
            task_queue.push(book);
        }

        // Уведомляем о завершении добавления задач
        all_tasks_added = true;

        // Обработка задач с использованием OpenMP
        #pragma omp parallel num_threads(10)
        {
            int thread_id = omp_get_thread_num() + 1;
            processTask(thread_id);
        }

        // Сортировка каталога
        std::sort(catalog.begin(), catalog.end());

        // Вывод каталога
        std::cout << "\nИтоговый каталог:" << std::endl;
        for (const auto& book : catalog) {
            std::cout << book.getBookInfo() << std::endl;
        }

        // Сохранение каталога в файл
        std::ofstream out_file("catalog_output.txt");
        if (out_file.is_open()) {
            for (const auto& book : catalog) {
                out_file << book.getBookInfo() << std::endl;
            }
            out_file.close();
            std::cout << "\nКаталог сохранен в файл catalog_output.txt." << std::endl;
        }

        // Удаление OpenMP мьютексов
        omp_destroy_lock(&task_lock);
        omp_destroy_lock(&catalog_lock);
    } catch (const std::exception& ex) {
        std::cerr << "Ошибка: " << ex.what() << std::endl;
        return 1;
    }
    return 0;
}

