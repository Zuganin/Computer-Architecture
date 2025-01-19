#include "book.cpp"
#include <pthread.h>
#include <queue>
#include <vector>
#include <iostream>
#include <algorithm>
#include <fstream>

// Глобальные переменные
pthread_mutex_t task_mutex;       // Мьютекс для синхронизации доступа к очереди задач
pthread_mutex_t catalog_mutex;    // Мьютекс для синхронизации доступа к каталогу книг
pthread_mutex_t output_mutex;     // Мьютекс для синхронизации вывода в консоль
std::queue<Book> task_queue;      // Очередь задач (каждая задача - это книга)
std::vector<Book> catalog;        // Каталог книг, куда добавляются обработанные задачи

// Структура для передачи данных в потоки
struct ThreadData {
    int thread_id;                // Идентификатор потока
};


// Функция обработки задач (работа потоков)
void* processTask(void* arg) {
    ThreadData* data = (ThreadData*)arg; // Получаем данные потока
    while (true) {
        // Захватываем мьютекс, чтобы безопасно работать с очередью задач
        pthread_mutex_lock(&task_mutex);
        if (task_queue.empty()) { // Если очередь пуста, завершаем работу
            pthread_mutex_unlock(&task_mutex);
            break;
        }
        Book task = task_queue.front(); // Извлекаем задачу из очереди
        task_queue.pop();
        pthread_mutex_unlock(&task_mutex); // Освобождаем мьютекс

        // Добавляем книгу в каталог, используя мьютекс для синхронизации
        pthread_mutex_lock(&catalog_mutex);
        catalog.push_back(task);
        pthread_mutex_unlock(&catalog_mutex);

        // Выводим информацию о выполнении задачи, синхронизируя доступ к консоли
        pthread_mutex_lock(&output_mutex);
        std::cout << "Студент " << data->thread_id << " успешно добавил книгу "
                  << task.getBookInfo() << " в каталог" << std::endl;
        pthread_mutex_unlock(&output_mutex);
    }
    return nullptr; // Завершаем поток
}

int main(int argc, char* argv[]) {
    // Проверка наличия флагов и аргументов командной строки
    if (argc < 2) {
        std::cerr << "Ошибка: Не указан режим работы. Используйте --generate, --console или --file <filename>.\n";
        return 1;
    }
    std::vector<Book> books; // Вектор для хранения исходных данных о книгах
    try {
        // Генерация случайных данных
        if (strcmp(argv[1], "-generate") == 0) {
            int num_books = 52; // По умолчанию генерируется 52 книг
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
        }
        // Если флаг не распознан
        else {
            throw std::runtime_error("Ошибка: Неизвестный флаг. Используйте -generate <numbers of book>, -console или -file <file name>.");
        }

        // Формирование структуры библиотеки
        auto library = Book::getBooksInCloset(books);
        std::cout << "Начальное состояние библиотеки:" << std::endl;
        Book::printLibrary(library);

        // Заполнение очереди задач
        for (const auto& book : books) {
            task_queue.push(book);
        }

        // Инициализация мьютексов
        pthread_mutex_init(&task_mutex, nullptr);
        pthread_mutex_init(&catalog_mutex, nullptr);
        pthread_mutex_init(&output_mutex, nullptr);

        // Создание потоков
        const int NUM_THREADS = 10;
        pthread_t threads[NUM_THREADS];
        ThreadData thread_data[NUM_THREADS];

        for (int i = 0; i < NUM_THREADS; ++i) {
            thread_data[i].thread_id = i + 1;
            pthread_create(&threads[i], nullptr, processTask, &thread_data[i]);
        }

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
        std::ofstream out_file("catalog_output.txt");
        if (out_file.is_open()) {
            for (const auto& book : catalog) {
                out_file << book.getBookInfo() << std::endl;
            }
            out_file.close();
            std::cout << "\nКаталог сохранен в файл catalog_output.txt." << std::endl;
        }

        // Удаление мьютексов
        pthread_mutex_destroy(&task_mutex);
        pthread_mutex_destroy(&catalog_mutex);
        pthread_mutex_destroy(&output_mutex);
    }
    catch (const std::exception& ex) {
        std::cerr << "Ошибка: " << ex.what() << std::endl;
        return 1;
    }
    return 0;

}




