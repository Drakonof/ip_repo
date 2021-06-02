#ifndef INC_TYPES__H
#define INC_TYPES__H

#include <stdint.h>
#include <stdlib.h>

#ifndef null_
#    define null_ NULL
#endif

#ifndef TRUE
#    define TRUE 1U
#endif

#ifndef FALSE
#    define FALSE 0
#endif

typedef enum {
	un_init_ = -2,
	error_,
	ok_,
}
status;

typedef enum {
	false_,
	true_
} boolean;

#endif /* INC_TYPES_H */
