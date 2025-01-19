#include "book.cpp"
#include <pthread.h>
#include <queue>
#include <vector>
#include <iostream>
#include <algorithm>
#include <fstream>

// Глобальные переменные
pthread_cond_t task_cond = PTHREAD_COND_INITIALIZER;  // Условная переменная для задач
pthread_cond_t catalog_cond = PTHREAD_COND_INITIALIZER; // Условная переменная для каталога
pthread_mutex_t task_mutex = PTHREAD_MUTEX_INITIALIZER; // Мьютекс для очереди задач
pthread_mutex_t catalog_mutex = PTHREAD_MUTEX_INITIALIZER; // Мьютекс для каталога
pthread_cond_t output_cond = PTHREAD_COND_INITIALIZER;  // Условная переменная для вывода
pthread_mutex_t output_mutex = PTHREAD_MUTEX_INITIALIZER; // Мьютекс для синхронизации вывода
std::queue<Book> task_queue;  // Очередь задач (каждая задача - это книга)
std::vector<Book> catalog;    // Каталог книг, куда добавляются обработанные задачи
bool all_tasks_added = false; // Флаг для завершения потоков
bool output_in_progress = false; // Флаг, указывающий на занятие консоли

// Структура для передачи данных в потоки
struct ThreadData {
    int thread_id; // Идентификатор потока
};


void* processTask(void* arg) {
    ThreadData* data = (ThreadData*)arg; // Получаем данные потока

    while (true) {
        pthread_mutex_lock(&task_mutex);

        // Ожидание задачи в очереди или завершения работы
        while (task_queue.empty() && !all_tasks_added) {
            pthread_cond_wait(&task_cond, &task_mutex);
        }

        // Если все задачи добавлены и очередь пуста, завершаем работу
        if (task_queue.empty() && all_tasks_added) {
            pthread_mutex_unlock(&task_mutex);
            break;
        }

        // Извлекаем задачу из очереди
        Book task = task_queue.front();
        task_queue.pop();
        pthread_mutex_unlock(&task_mutex);

        // Добавляем книгу в каталог
        pthread_mutex_lock(&catalog_mutex);
        catalog.push_back(task);
        pthread_mutex_unlock(&catalog_mutex);

        // Уведомляем о добавлении в каталог
        pthread_cond_signal(&catalog_cond);

        // Синхронизируем вывод
        pthread_mutex_lock(&output_mutex);
        while (output_in_progress) {
            pthread_cond_wait(&output_cond, &output_mutex);
        }
        output_in_progress = true;

        // Выводим информацию о выполнении задачи
        std::cout << "Студент " << data->thread_id << " успешно добавил книгу "
                  << task.getBookInfo() << " в каталог" << std::endl;

        output_in_progress = false;
        pthread_cond_signal(&output_cond);
        pthread_mutex_unlock(&output_mutex);
    }

    return nullptr; // Завершаем поток
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

        // Инициализация потоков
        const int NUM_THREADS = 10;
        pthread_t threads[NUM_THREADS];
        ThreadData thread_data[NUM_THREADS];

        for (int i = 0; i < NUM_THREADS; ++i) {
            thread_data[i].thread_id = i + 1;
            pthread_create(&threads[i], nullptr, processTask, &thread_data[i]);
        }

        // Заполнение очереди задач
        for (const auto& book : books) {
            pthread_mutex_lock(&task_mutex);
            task_queue.push(book);
            pthread_cond_signal(&task_cond); // Уведомляем потоки о новой задаче
            pthread_mutex_unlock(&task_mutex);
        }

        // Уведомляем о завершении добавления задач
        pthread_mutex_lock(&task_mutex);
        all_tasks_added = true;
        pthread_cond_broadcast(&task_cond);
        pthread_mutex_unlock(&task_mutex);

        // Ожидание завершения потоков
        for (int i = 0; i < NUM_THREADS; ++i) {
            pthread_join(threads[i], nullptr);
        }

        // Сортировка каталога
        std::sort(catalog.begin(), catalog.end());

        // Вывод каталога
        std::cout << "\nИтоговый каталог:" << std::endl;
        for (const auto& book : catalog) {
            std::cout << book.getBookInfo() << std::endl;
        }

        // Сохранение каталога в файл
        std::ofstream out_file("catalog_output500.txt");
        if (out_file.is_open()) {
            for (const auto& book : catalog) {
                out_file << book.getBookInfo() << std::endl;
            }
            out_file.close();
            std::cout << "\nКаталог сохранен в файл catalog_output.txt." << std::endl;
        }

        // Удаление условных переменных и мьютексов
        pthread_cond_destroy(&task_cond);
        pthread_cond_destroy(&catalog_cond);
        pthread_mutex_destroy(&task_mutex);
        pthread_mutex_destroy(&catalog_mutex);
        pthread_cond_destroy(&output_cond);
        pthread_mutex_destroy(&output_mutex);
    } catch (const std::exception& ex) {
        std::cerr << "Ошибка: " << ex.what() << std::endl;
        return 1;
    }
    return 0;
}
