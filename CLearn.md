## C++

+ NULL被定义为0;nullptr等价于NULL。

+ `->`是可以是结构体指针指向其成员;可以对象指针调用其方法。

+ C/C++标准库函数定义可以在/usr/include中找到。

+ extern关键字
  - c++解决多态问题用函数名和参数联合起来生成一个中间函数名，为了保持不生成中间函数名就要如下。
  ```
  #ifdef __cplusplus
  extern "C"{
  #endif
  ```
  - 在头文件中定义的函数前加extern表示可能在其他源文件中定义。

+ `time_t time(time_t *__timer)`在头文件`time.h`中表示返回当前时间，可以加timer。

+ `int pipe(int pipefd[2])`创建一个管道来进程间通讯，`pipefd[0]`是读取端，`pipefd[1]`是写入端。

+ `fopen;freopen`打开指定路径文件。模式a是在文件最后append，模式r打开只读文件，stream在文件开头。
```
FILE *fopen(const char *path, const char *mode);
FILE *fdopen(int fd, const char *mode);
FILE *freopen(const char *path, const char *mode, FILE *stream);
```

+ `setbuf`一些打开的stream改变他的buffer。
```
void setbuf(FILE *stream, char *buf);
```

+ STDIN_FILENO;STDOUT_FILENO;STDERR_FILENO是文件描述符，是非负整数。stdin是`File *`类型。

+ `dup2`newfd是目标描述符，oldfd源描述符。目标变成了源的副本。
```
int dup2(int oldfd, int newfd);
eg: dup2(pipe[1], STDOUT_FILENO);
```

+ `getline()`读取整句从stream中，把存储buffer的地址放在*lineptr中。
```
ssize_t getline(char **lineptr, size_t *n, FILE *stream);
```

+ `void *realloc(void *ptr, size_t size);`用来改变已分配空间的ptr指向的内存空间，大小为入参大小，并返回指针，原指针被自动释放。

+ `void *calloc(size_t nmemb, size_t size);`给array nmemb元素分配内存

+ `int access(const char *pathname, int mode)`调用的程式能否进入给定的pathname文件，查看权限。

+ `strrchr`locate character in string

+ 当if(指针)，就是判断当前指针是否为空。

+ `struc stat`需要引入头文件`<sys/stat.h>`，这个结构体是用来描述Linux系统文件中的文件属性的结构。
```
int stat(const char *path, struct stat *struct_stat);
int lstat(const char *path,struct stat *struct_stat);
ENOENT：路径名的部分组件不存在，或路径名是空字串
struct stat {
    mode_t     st_mode;      //文件对应的模式，文件，目录等
    ino_t      st_ino;       //inode节点号
    dev_t      st_dev;       //设备号码
    dev_t      st_rdev;      //特殊设备号码
    nlink_t    st_nlink;     //文件的连接数
    uid_t      st_uid;       //文件所有者
    gid_t      st_gid;       //文件所有者对应的组
    off_t      st_size;      //普通文件，对应的文件字节数
    time_t     st_atime;     //文件最后被访问的时间
    time_t     st_mtime;     //文件内容最后被修改的时间
    time_t     st_ctime;     //文件状态改变时间
    blksize_t  st_blksize;   //文件内容对应的块大小
    blkcnt_t   st_blocks;    //伟建内容对应的块数量
};
```

+ `int symlink(const char* oldpath, const char* newpath);`以参数newpath指定的名称来建立一个新的连接到参数oldpath所指定的已存在的文件。

+ `FILE *setmntent(const char *filename, const char *type);`打开一个文件描述符。

+ `strndup`拷贝一个字符串

+ `strlcat`连接字符串

+ `snprintf`保证以null结尾

+ cpp对成员初始化，使用初始化列表，性能上有提升
```
class Device {
    public：
        Device(RecoveryUI* ui) : ui_(ui) {} 
    private:
        RecoveryUI* ui_;
}
```

+ cpp纯虚函数需要子类继承后重写实现不需要virtual关键字，子类实例化的时候声明类型为父类类型，则可以调用子类实现的方法，但是不能调用子类的方法
```
virtual void SetStage(int current, int max) = 0
```

+ `static_cast<float>`将表达式转换为float类型但是没有运行时类型检查来保证转换的安全性

+ libpng读取png流程
```
/* 打开指定png图片文件 */
FILE* fp = fopen(resPath, "rb");
/* 读取sizeof(header)个字节数据 */
byteRead = fread(header, 1, sizeof(header));
/* 检测数据是否为PNG的签名 */ 
int png_sig_cmp(png_bytep buf, png_size_t from, size_t to);
/* 创建png read struct */
*png_ptr = png_create_read_struct(...);
/* 创建info struct*/
*info_ptr = png_create_info_struct(...);
/* 设置错误处理 */
setjmp(png_jmpbuf(*png_ptr));
/* 开始读文件 */
png_init_io(*png_ptr, fp);
/* 库会跳过相应的数据*/
png_set_sig_bytes(*png_ptr, sizeof(header));
/* 获取图片信息 */
png_read_info(*png_ptr, *info_ptr);
/* 调用来查询info_ptr中的信息 */
png_get_IHDR(...);
/* 设置参数 */
png_set_expand_gray_1_2_4_to_8
/* 读完后清除释放分配的内存 */
png_destroy_read_struct(...);
```

+ munmap调用删除指定的地址范围和在这范围内导致远引用地址所产生的违法的内存引用

+ mmap将一个文件或者其它对象映射进内存。文件被映射到多个页上，如果文件的大小不是所有页的大小之和，最后一个页不被使用的空间将会清零。mmap在用户空间映射调用系统中作用很大

+ `vector.emplace_back`和`push_back`都是向容器中添加数据

+ `INLINE`关键字是内联函数，将小函数定义在头文件中，为了减小频繁调用小函数所导致的栈空间不足。

+ 内存地址从低到高地址，数组中下标低的内存地址低

+ 有效位从高到低`0x11223344`

+ little-endian
  - 最低有效位落在低地址上`44 33 22 11`

+ big-endian
  - 最高有效位落在低地址上`11 22 33 44`

```
int is_little_endian_a(void){
    unsigned short int flag = 0x4321;
    if(*(unsigned char *)&flag == 0x21){
        return 1;
    } else {
        return 0;
    }
}
```

+ linux进程与线程的区别
  - 进程是有独立空间的，系统会给其分配空间，但是不会给线程分配空间
  - 线程是进程的一部分，如果就一个线程，那这个进程是单线程的，创建了新的线程会共享进程中的资源
  - 进程控制块PCB比线程控制块TCP要大

+ 联合Union大小必须满足两个条件
  - 大小足够容纳最宽的成员
  - 大小能被其包含的所有基本数据类型的大小所整除

+ 关于字符串和字符数组，sizeof和strlen
```
char a[] = "abc";          // sizeof: 4 strlen: 3
char a[] = {'a','b','c'};  // sizeof: 3 strlen: 3
char a[3] = {'a','b','c'}; // sizeof: 3 strlen: 3
char* p = "abc";           // sizeof: 4 strlen: 3

char a[] = "abc"; // 等价于 char a[4] = {'a','b','c','\0'};
char a[] = "abc"; // 相同于 char a[] = {"abc"}; 花括号可有可无
char str[]; str = "abc"; // 错误。这种方式只能用在初始化的时候不能用做赋值

char a[0]; // 声明是可以的sizeof大小为0，但是没有初始化其内容是乱的
char a[]; // 这种声明方式是非法的会报array size missing
char a[10]; // sizeof大小为10，已分配空间但是没有初始化
```

+ 将宏所定义的多条表达式放在大括号中
```
#defineINTI_RECT_VALUE( a, b )\
{\
    a = 0;\
    b = 0;\
}
```

+ 任意两个指针变量是可以用比较运算符的"== > <"

+ 用括号来保持优先级，避免使用默认优先级

+ memset fill memory with a constant byte, 因为是void*类型，所以是可以任何指针类型进行字节的set。
```
void *memset(void *s, int c, size_t n);

int a[24];
memset(a, 0, sizeof(a));
```

+ 二维数组高维是不能省略的
```
int a[3][4] = {{1,3,5,7},{9,11,13,15},{17,19,21,23}};
a[0]; // 可以看做是第一行一维数组，第一行的首地址
void Func(int arrary[3][10]);
void Func(int array[][10]);
不对的是:
void Func(int array[3][]);
```

+ C中的static
  - 局部变量前的static
  - 全局变量前的static
  - 函数前的static

+ memcpy和strcpy
  - 复制内容不同，strcpy只能复制字符串，memcpy可以复制任意内容。
  - 复制方法不同，strcpy不需要指定长度以字符串结束符"\0"结尾。memcpy以第三个参数决定复制的长度。

+ 友元函数
  - 类A函数访问类B的成员，类A函数就是类B的友元函数，即其他类成员函数直接访问该类私有变量
  - 运算符重载的某些场合需要使用友元
  - 两个类要共享数据的时候
```
// 普通函数友元函数
class INTEGER
{
    friend void Print(const INTEGER& obj);//声明友元函数
};

void Print(const INTEGER& obj)
{
    //函数体
}

void main()
{
　　INTEGER obj;
　　Print(obj); //直接调用
}

// 类Y的所有成员函数都为类X友元函数—友元类
class girl;
class boy
{
public:
　　void disp(girl &);
};

void boy::disp(girl &x) //函数disp()为类boy的成员函数，也是类girl的友元函数

{
　　cout<<"girl's name is:"<<x.name<<",age:"<<x.age<<endl;//借助友元，在boy的成员函数disp中，借助girl的对象，直接访问girl的私有变量
}

class girl
{
private：
　　char *name;
　　int age;
　　friend boy; //声明类boy是类girl的友元
};
```

+ qsort功能是排序nmemb个元素，base指向array的开头，根据compar函数比较元素进行ascending的排序。
```
void qsort(void *base, size_t nmemb, size_t size, int(*compar)(const void *, const void *))
```

+ ssize_t和size_t区别
```
// 从字面意思来说
ssize_t = signed size_t
// 使用位置
// 对于缓冲区大小等等非负值的长度时一般使用size_t
// 对于读取文件之类可能返回<0的函数是，则使用ssize_t
ssize_t (*read)(struct file* filp, char __user* buf, loff_t* pos);
```

+ container_of在Linux内核中是一个常用的宏，用于从包含在某个结构中的指针获得结构本身的指针，通俗地讲就是通过结构体变量中某个成员的首地址进而获得整个结构体变量的首地址。
```
#define container_of(ptr, type, member) ({      \
  const typeof( ((type *)0)->member ) *__mptr = (ptr);    \
  (type *)( (char *)__mptr - offsetof(type,member) );})

// 第一步，首先定义一个临时的数据类型（通过typeof( ((type *)0)->member )获得）与ptr相同的指针变量__mptr，然后用它来保存ptr的值。

// 第二步，用(char *)__mptr减去member在结构体中的偏移量，得到的值就是整个结构体变量的首地址（整个宏的返回值就是这个首地址）。
```

