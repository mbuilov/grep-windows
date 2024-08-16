/* public domain */

/* compile as:
  gcc testrepl.c -o testrepl
 or
  cl.exe testrepl.c /Fetestrepl.exe
*/

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#else /* !_WIN32 */
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#define HANDLE int
#endif /* !_WIN32 */

#define STACK_BUF_SIZE 128

static int write_(HANDLE file, const void *const buf, const size_t len)
{
	size_t to_write = len;
	if (to_write > (unsigned)-1/2)
		to_write = (unsigned)-1/2;
#ifdef _WIN32
	if (to_write > (DWORD)-1)
		to_write = (DWORD)-1;
	{
		DWORD written = 0;
		if (!WriteFile(file, buf, (DWORD)to_write, &written, NULL))
			return -1;
		return (int)written;
	}
#else
	const ssize_t s = write(file, buf, to_write);
	if (s < 0)
		return -1;
	return (int)s;
#endif
}

static int read_(HANDLE file, void *const buf, const size_t len)
{
	size_t to_read = len;
	if (to_read > (unsigned)-1/2)
		to_read = (unsigned)-1/2;
#ifdef _WIN32
	if (to_read > (DWORD)-1)
		to_read = (DWORD)-1;
	{
		DWORD filled = 0;
		if (!ReadFile(file, buf, (DWORD)to_read, &filled, NULL)) {
			if (ERROR_BROKEN_PIPE == GetLastError())
				return 0;
			return -1;
		}
		return (int)filled;
	}
#else
	const ssize_t s = read(file, buf, to_read);
	if (s < 0)
		return -1;
	return (int)s;
#endif
}

static int write_buf(HANDLE file, const void *const buf, const size_t len)
{
	size_t written = 0;
	while (written < len) {
		const int r = write_(file, (const unsigned char*)buf + written, len - written);
		if (r <= 0)
			return -1;
		written += (unsigned)r;
	}
	return 0;
}

static int read_buf(HANDLE file, void *const buf, const size_t len/*<=(unsigned)-1/2*/)
{
	size_t filled = 0;
	while (filled < len) {
		const int r = read_(file, (unsigned char*)buf + filled, len - filled);
		if (r < 0)
			return -1;
		if (r == 0)
			break;
		filled += (unsigned)r;
	}
	return (int)filled;
}

static HANDLE get_stderr_handle(void)
{
#ifdef _WIN32
	HANDLE h = GetStdHandle(STD_ERROR_HANDLE);
#else
	int h = fileno(stderr);
#endif
	return h;
}

static int print_usage(const char *prog)
{
	HANDLE h = get_stderr_handle();
	const size_t len = strlen(prog);
	write_buf(h, prog, len);
#define STR1 ": read standard input and write to standard output translating bytes b1 -> b2 or deleting bytes b1\nusage:\n"
	write_buf(h, STR1, sizeof(STR1) - 1);
	write_buf(h, prog, len);
#define STR2 " b1 b2\nwhere: b1/b2 - bytes to translate from/to, specified as hexadecimal numbers, e.g.: 1F B\n"
	write_buf(h, STR2, sizeof(STR2) - 1);
#define STR3 "or\n"
	write_buf(h, STR3, sizeof(STR3) - 1);
	write_buf(h, prog, len);
#define STR4 " b\nwhere: b - bytes to delete, e.g.: 0d\n"
	write_buf(h, STR4, sizeof(STR4) - 1);
	write_buf(h, STR3, sizeof(STR3) - 1);
	write_buf(h, prog, len);
#define STR5 " +offset b\nwhere: offset - offset (non-negative decimal number) from the input beginning where to replace source byte with b\n"
	write_buf(h, STR5, sizeof(STR5) - 1);
	write_buf(h, STR3, sizeof(STR3) - 1);
	write_buf(h, prog, len);
#define STR6 " +offset\nwhere: offset - offset (non-negative decimal number) from the input beginning where to delete source byte\n"
	write_buf(h, STR6, sizeof(STR6) - 1);
	return 1;
}

static char *print_num(char *end, unsigned n)
{
	do {
		*--end = (n % 10) + '0';
		n = n/10;
	} while (n);
	return end;
}

#ifndef _WIN32
static char *print_inum(char *end, int i)
{
	const unsigned n = i >= 0 ? (unsigned)i : (unsigned)-(i + 1) + 1;
	end = print_num(end, n);
	if (i < 0)
		*--end = '-';
	return end;
}
#endif

#ifdef _WIN32
static void write_num(HANDLE h, const unsigned n)
{
	char num_buf[64];
	char *const num = print_num(&num_buf[sizeof(num_buf)], n);
	write_buf(h, num, (size_t)(&num_buf[sizeof(num_buf)] - num));
}
#endif

#ifndef _WIN32
static void write_inum(HANDLE h, const int i)
{
	char num_buf[64];
	char *const num = print_inum(&num_buf[sizeof(num_buf)], i);
	write_buf(h, num, (size_t)(&num_buf[sizeof(num_buf)] - num));
}
#endif

static int read_error(void)
{
#ifdef _WIN32
	const DWORD err = GetLastError();
#else
	const int err = errno;
#endif
	HANDLE h = get_stderr_handle();
#define READ_ERR "failed to read from standard input stream, error: "
	write_buf(h, READ_ERR, sizeof(READ_ERR) - 1);
#ifdef _WIN32
	write_num(h, err);
#else
	write_inum(h, err);
#endif
	write_buf(h, "\n", 1);
	return 3;
}

static int write_error(void)
{
#ifdef _WIN32
	const DWORD err = GetLastError();
#else
	const int err = errno;
#endif
	HANDLE h = get_stderr_handle();
#define WRITE_ERR "failed to write to standard output stream, error: "
	write_buf(h, WRITE_ERR, sizeof(WRITE_ERR) - 1);
#ifdef _WIN32
	write_num(h, err);
#else
	write_inum(h, err);
#endif
	write_buf(h, "\n", 1);
	return 4;
}

static int translate(const unsigned long long offs, const int repl, const unsigned char b1, const unsigned char b2)
{
#ifdef _WIN32
	HANDLE rh = GetStdHandle(STD_INPUT_HANDLE);
	HANDLE wh = GetStdHandle(STD_OUTPUT_HANDLE);
#else
	int rh = fileno(stdin);
	int wh = fileno(stdout);
#endif
	unsigned char buf[STACK_BUF_SIZE];
	unsigned long long pos = 0;
	for (;;) {
		int r = read_buf(rh, buf, sizeof(buf));
		if (r < 0)
			return read_error();
		if (r == 0)
			return 0;
		if ((unsigned long long)-1 == offs) {
			if (repl) {
				int i = 0;
				do {
					if (b1 == buf[i])
						buf[i] = b2;
				} while (++i != r);
			}
			else {
				int i = 0, at = 0;
				do {
					if (b1 != buf[i]) {
						if (at != i)
							buf[at] = buf[i];
						at++;
					}
				} while (++i != r);
				r = at;
			}
		}
		else {
			const unsigned len = (unsigned)r;
			if (pos <= offs && len > offs - pos) {
				if (repl)
					buf[offs - pos] = b2;
				else {
					unsigned i = (unsigned)(offs - pos);
					while (++i < len)
						buf[i - 1] = buf[i];
					r--;
				}
			}
			if (len <= (unsigned long long)-1 - pos)
				pos += len;
			else
				pos = (unsigned long long)-1;
		}
		if (write_buf(wh, buf, (unsigned)r) < 0)
			return write_error();
	}
}

static int decode_hex_char(const char c)
{
	if ('0' <= c && c <= '9')
		return (int)(c - '0');
	if ('a' <= c && c <= 'f')
		return (int)(c - 'a') + 10;
	if ('A' <= c && c <= 'F')
		return (int)(c - 'A') + 10;
	return -1;
}

static int parse_byte(const char *const a)
{
	const int x = decode_hex_char(a[0]);
	if (x >= 0) {
		if (!a[1])
			return x;
		{
			const int y = decode_hex_char(a[1]);
			if (!a[2])
				return x*16 + y;
		}
	}
	{
		HANDLE h = get_stderr_handle();
		const size_t byte_len = strlen(a);
#define PARSE_ERR1 "failed to parse byte: \""
		write_buf(h, PARSE_ERR1, sizeof(PARSE_ERR1) - 1);
		write_buf(h, a, byte_len);
#define PARSE_ERR2 "\", expecting hexadecimal number, e.g.: F or 1A\n"
		write_buf(h, PARSE_ERR2, sizeof(PARSE_ERR2) - 1);
	}
	return -1;
}

static unsigned long long parse_offs(const char *const a)
{
	if ('0' <= *a && *a <= '9') {
		unsigned long long offs = (unsigned)(*a - '0');
		const char *c = a;
		for (;;) {
			if (!*++c)
				return offs;
			if (*c < '0' || '9' < *c)
				break;
			if (offs > (unsigned long long)-1/10 ||
				(unsigned)(*c - '0') >= (unsigned long long)-1 - offs*10)
			{
				HANDLE h = get_stderr_handle();
				const size_t byte_len = strlen(a);
#define PARSE_ERR3 "too big offset: \""
				write_buf(h, PARSE_ERR3, sizeof(PARSE_ERR3) - 1);
				write_buf(h, a, byte_len);
#define PARSE_ERR4 "\"\n"
				write_buf(h, PARSE_ERR4, sizeof(PARSE_ERR4) - 1);
				return (unsigned long long)-1;
			}
			offs = offs*10 + (unsigned)(*c - '0');
		}
	}
	{
		HANDLE h = get_stderr_handle();
		if (!*a) {
#define PARSE_ERR5 "empty offset\n"
			write_buf(h, PARSE_ERR5, sizeof(PARSE_ERR5) - 1);
		}
		else {
			const size_t byte_len = strlen(a);
#define PARSE_ERR6 "failed to parse offset: \""
			write_buf(h, PARSE_ERR6, sizeof(PARSE_ERR6) - 1);
			write_buf(h, a, byte_len);
#define PARSE_ERR7 "\", expecting non-negative decimal number, e.g.: 012345678\n"
			write_buf(h, PARSE_ERR7, sizeof(PARSE_ERR7) - 1);
		}
	}
	return (unsigned long long)-1;
}

int main(int argc, char *argv[])
{
	int b1 = 0, b2 = 0;
	unsigned long long offs = (unsigned long long)-1;
	if (argc != 2 && argc != 3)
		return print_usage(argv[0]);
	if ((('+' == argv[1][0]) ?
			((unsigned long long)-1 == (offs = parse_offs(&argv[1][1]))) :
			((b1 = parse_byte(argv[1])) < 0)) ||
		(3 == argc && (b2 = parse_byte(argv[2])) < 0))
	{
		return 2;
	}
	return translate(offs, 3 == argc, (unsigned char)b1, (unsigned char)b2);
}
