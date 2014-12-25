#include "pbc.h"
#include "context.h"
#include "alloc.h"
#include "varint.h"
#include "map.h"
#include "proto.h"

#include <stdint.h>
#include <string.h>
#include <assert.h>

#ifndef _MSC_VER
#include <stdbool.h>
#else
#define bool int
#define true 1
#define false 0
#endif

#define WMESSAGE_SIZE 64

struct pbc_wmessage {
	struct _message *type;
	uint8_t * buffer;
	uint8_t * ptr;
	uint8_t * endptr;
	pbc_array sub;
	struct map_sp *packed;
	struct heap * heap;
};

struct _packed {
	int id;
	int ptype;
	pbc_array data;
};

static struct pbc_wmessage *
_wmessage_new(struct heap *h, struct _message *msg) {
	struct pbc_wmessage * m = (struct pbc_wmessage *)_pbcH_alloc(h, sizeof(*m));
	m->type = msg;
	m->buffer = (uint8_t *)_pbcH_alloc(h, WMESSAGE_SIZE);
	m->ptr = m->buffer;
	m->endptr = m->buffer + WMESSAGE_SIZE;
	_pbcA_open_heap(m->sub, h);
	m->packed = NULL;
	m->heap = h;

	return m;
}

struct pbc_wmessage * 
pbc_wmessage_new(struct pbc_env * env, const char *type_name) {
	struct heap *h = NULL;
	struct _message * msg = NULL;

	msg = _pbcP_get_message(env, type_name);
	if (msg == NULL)
		return NULL;
	h = _pbcH_new(0);
	return _wmessage_new(h, msg);
}

void 
pbc_wmessage_delete(struct pbc_wmessage *m) {
	if (m) {
		_pbcH_delete(m->heap);
	}
}

static void
_expand_message(struct pbc_wmessage *m, int sz) {
	uint8_t * buffer = NULL;
	int old_size;

	if (m->ptr + sz > m->endptr) {
		int cap = m->endptr - m->buffer;
		sz = m->ptr + sz - m->buffer;
		do {
			cap = cap * 2;
		} while ( sz > cap ) ;
		old_size = m->ptr - m->buffer;
		buffer = (uint8_t *)_pbcH_alloc(m->heap, cap);
		memcpy(buffer, m->buffer, old_size);
		m->ptr = buffer + (m->ptr - m->buffer);
		m->endptr = buffer + cap;
		m->buffer = buffer;
	}
}

static struct _packed *
_get_packed(struct pbc_wmessage *m , struct _field *f , const char *key) {
	struct _packed *p = NULL;
	void ** v;

	if (m->packed == NULL) {
		m->packed = _pbcM_sp_new(4, m->heap);
	}
	v = _pbcM_sp_query_insert(m->packed , key);
	if (*v == NULL) {
		*v = _pbcH_alloc(m->heap, sizeof(struct _packed));
		p = (struct _packed *)*v;
		p->id = f->id;
		p->ptype = f->type;
		_pbcA_open_heap(p->data, m->heap);
		return p;
	}
	return (struct _packed *)*v;
}

static void
_packed_integer(struct pbc_wmessage *m, struct _field *f, const char *key , uint32_t low, uint32_t hi) {
	pbc_var var;
	struct _packed * packed = NULL;

	packed = _get_packed(m,f,key);
	
	var->integer.low = low;
	var->integer.hi = hi;
	_pbcA_push(packed->data , var);
}

static void
_packed_real(struct pbc_wmessage *m, struct _field *f, const char *key , double v) {
	pbc_var var;

	struct _packed * packed = NULL;
	packed = _get_packed(m,f,key);
	
	var->real = v;
	_pbcA_push(packed->data , var);
}

static inline void
int64_encode(uint32_t low, uint32_t hi , uint8_t * buffer) {
	buffer[0] = (uint8_t)(low & 0xff);
	buffer[1] = (uint8_t)(low >> 8 & 0xff);
	buffer[2] = (uint8_t)(low >> 16 & 0xff);
	buffer[3] = (uint8_t)(low >> 24 & 0xff);
	buffer[4] = (uint8_t)(hi & 0xff);
	buffer[5] = (uint8_t)(hi >> 8 & 0xff);
	buffer[6] = (uint8_t)(hi >> 16 & 0xff);
	buffer[7] = (uint8_t)(hi >> 24 & 0xff);
}

static inline void
int32_encode(uint32_t low, uint8_t * buffer) {
	buffer[0] = (uint8_t)(low & 0xff);
	buffer[1] = (uint8_t)(low >> 8 & 0xff);
	buffer[2] = (uint8_t)(low >> 16 & 0xff);
	buffer[3] = (uint8_t)(low >> 24 & 0xff);
}

int 
pbc_wmessage_integer(struct pbc_wmessage *m, const char *key, uint32_t low, uint32_t hi) {
	int id;

	struct _field * f = (struct _field *)_pbcM_sp_query(m->type->name,key);
	if (f==NULL) {
		// todo : error
		m->type->env->lasterror = "wmessage_interger query key error";
		return -1;
	}
	if (f->label == LABEL_PACKED) {
		_packed_integer(m , f, key , low, hi);
		return 0;		
	}
	if (f->label == LABEL_OPTIONAL) {
		if (f->type == PTYPE_ENUM) {
			if (low == f->default_v->e.id)
				return 0;
		} else {
			if (low == f->default_v->integer.low &&
				hi == f->default_v->integer.hi) {
				return 0;
			}
		}
	}
	id = f->id << 3;

	_expand_message(m,20);
	switch (f->type) {
	case PTYPE_INT64:
	case PTYPE_UINT64: 
	case PTYPE_INT32:
		id |= WT_VARINT;
		m->ptr += _pbcV_encode32(id, m->ptr);
		m->ptr += _pbcV_encode((uint64_t)low | (uint64_t)hi << 32 , m->ptr);
		break;
	case PTYPE_UINT32:
	case PTYPE_ENUM:
	case PTYPE_BOOL:
		id |= WT_VARINT;
		m->ptr += _pbcV_encode32(id, m->ptr);
		m->ptr += _pbcV_encode32(low, m->ptr);
		break;
	case PTYPE_FIXED64:
	case PTYPE_SFIXED64:
		id |= WT_BIT64;
		m->ptr += _pbcV_encode32(id, m->ptr);
		int64_encode(low,hi,m->ptr);
		m->ptr += 8;
		break;
	case PTYPE_FIXED32:
	case PTYPE_SFIXED32:
		id |= WT_BIT32;
		m->ptr += _pbcV_encode32(id, m->ptr);
		int32_encode(low,m->ptr);
		m->ptr += 4;
		break;
	case PTYPE_SINT32:
		id |= WT_VARINT;
		m->ptr += _pbcV_encode32(id, m->ptr);
		m->ptr += _pbcV_zigzag32(low, m->ptr);
		break;
	case PTYPE_SINT64:
		id |= WT_VARINT;
		m->ptr += _pbcV_encode32(id, m->ptr);
		m->ptr += _pbcV_zigzag((uint64_t)low | (uint64_t)hi << 32 , m->ptr);
		break;
	}

	return 0;
}

int
pbc_wmessage_real(struct pbc_wmessage *m, const char *key, double v) {
	int id;

	struct _field * f = (struct _field *)_pbcM_sp_query(m->type->name,key);
	if (f == NULL) {
		// todo : error
		m->type->env->lasterror = "wmessage_real query key error";
		return -1;
	}
	if (f->label == LABEL_PACKED) {
		_packed_real(m , f, key , v);
		return 0;		
	}

	if (f->label == LABEL_OPTIONAL) {
		if (v == f->default_v->real)
			return 0;
	}
	id = f->id << 3;
	_expand_message(m,18);
	switch (f->type) {
	case PTYPE_FLOAT: {
		id |= WT_BIT32;
		m->ptr += _pbcV_encode32(id, m->ptr);
		float_encode(v , m->ptr);
		m->ptr += 4;
		break;
	}
	case PTYPE_DOUBLE:
		id |= WT_BIT64;
		m->ptr += _pbcV_encode32(id, m->ptr);
		double_encode(v , m->ptr);
		m->ptr += 8;
		break;
	}

	return 0;
}

int
pbc_wmessage_string(struct pbc_wmessage *m, const char *key, const char * v, int len) {

	bool varlen = false;
	int enum_id = 0,err,id;
	char * temp = NULL;

	struct _field * f = (struct _field *)_pbcM_sp_query(m->type->name,key);
	if (f == NULL) {
		// todo : error
		m->type->env->lasterror = "wmessage_string query key error";
		return -1;
	}

	if (len <=0) {
		varlen = true;
		// -1 for add '\0'
		len = strlen(v) - len;
	}
	if (f->label == LABEL_PACKED) {
		if (f->type == PTYPE_ENUM) {
			temp = (char *)alloca(len + 1);
			if (!varlen || v[len] != '\0') {
				memcpy(temp,v,len);
				temp[len]='\0';
				v = temp;
			}
			
			err = _pbcM_si_query(f->type_name.e->name, v , &enum_id);
			if (err) {
				// todo : error , invalid enum
				m->type->env->lasterror = "wmessage_string packed invalid enum";
				return -1;
			}
			_packed_integer(m , f, key , enum_id , 0);
		}
		return 0;	
	}

	if (f->label == LABEL_OPTIONAL) {
		if (f->type == PTYPE_ENUM) {
			if (strncmp(v , f->default_v->e.name, len) == 0 && f->default_v->e.name[len] =='\0') {
				return 0;
			}
		} else if (f->type == PTYPE_STRING) {
			if (len == f->default_v->s.len &&
				strcmp(v, f->default_v->s.str) == 0) {
				return 0;
			}
		}
	}
	id = f->id << 3;
	_expand_message(m,20);
	switch (f->type) {
	case PTYPE_ENUM : {
		temp = (char *)alloca(len+1);
		if (!varlen || v[len] != '\0') {
			memcpy(temp,v,len);
			temp[len]='\0';
			v = temp;
		}
		
		err = _pbcM_si_query(f->type_name.e->name, v, &enum_id);
		if (err) {
			// todo : error , enum invalid
			m->type->env->lasterror = "wmessage_string invalid enum";
			return -1;
		}
		id |= WT_VARINT;
		m->ptr += _pbcV_encode32(id, m->ptr);
		m->ptr += _pbcV_encode32(enum_id, m->ptr);
		break;
	}
	case PTYPE_STRING:
	case PTYPE_BYTES:
		id |= WT_LEND;
		m->ptr += _pbcV_encode32(id, m->ptr);
		m->ptr += _pbcV_encode32(len, m->ptr);
		_expand_message(m,len);
		memcpy(m->ptr , v , len);
		m->ptr += len;
		break;
	}

	return 0;
}

struct pbc_wmessage * 
pbc_wmessage_message(struct pbc_wmessage *m, const char *key) {
	pbc_var var;
	struct _field * f = (struct _field *)_pbcM_sp_query(m->type->name,key);
	if (f == NULL) {
		// todo : error
		m->type->env->lasterror = "wmessage_message query key error";
		return NULL;
	}
	
	var->p[0] = _wmessage_new(m->heap, f->type_name.m);
	var->p[1] = f;
	_pbcA_push(m->sub , var);
	return (struct pbc_wmessage *)var->p[0];
}

static void
_pack_packed_64(struct _packed *p,struct pbc_wmessage *m) {
	int n = pbc_array_size(p->data);
	int len = n * 8;
	int i;
	pbc_var var;
	_expand_message(m,10 + len);
	m->ptr += _pbcV_encode32(len, m->ptr);
	switch (p->ptype) {
	case PTYPE_DOUBLE:
		for (i=0;i<n;i++) {
			_pbcA_index(p->data, i, var);
			double_encode(var->real , m->ptr + i * 8);
		}
		break;
	default:
		for (i=0;i<n;i++) {
			_pbcA_index(p->data, i, var);
			int64_encode(var->integer.low , var->integer.hi, m->ptr + i * 8);
		}
		break;
	}
	m->ptr += len;
}

static void
_pack_packed_32(struct _packed *p,struct pbc_wmessage *m) {
	int n = pbc_array_size(p->data);
	int len = n * 4;
	int i;
	pbc_var var;
	_expand_message(m,10 + len);
	m->ptr += _pbcV_encode32(len, m->ptr);
	switch (p->ptype) {
	case PTYPE_FLOAT:
		for (i=0;i<n;i++) {
			_pbcA_index(p->data, i, var);
			float_encode(var->real , m->ptr + i * 8);
		}
		break;
	default:
		for (i=0;i<n;i++) {
			_pbcA_index(p->data, i, var);
			int32_encode(var->integer.low , m->ptr + i * 8);
		}
		break;
	}
	m->ptr += len;
}

static void
_pack_packed_varint(struct _packed *p,struct pbc_wmessage *m) {
	int i;
	pbc_var var;
	int len_len;
	int end_offset,end_len;

	int n = pbc_array_size(p->data);

	int offset = m->ptr - m->buffer;
	int len = n * 2;
	if (p->ptype == PTYPE_BOOL) {
		len = n;
	}

	_expand_message(m,10 + len);
	len_len = _pbcV_encode32(len, m->ptr);
	m->ptr += len_len;

	switch (p->ptype) {
	case PTYPE_INT64:
	case PTYPE_UINT64:
		for (i=0;i<n;i++) {
			_pbcA_index(p->data, i, var);
			_expand_message(m,10);
			m->ptr += _pbcV_encode((uint64_t)var->integer.low | (uint64_t)var->integer.hi << 32 , m->ptr);
		}
		break;
	case PTYPE_INT32:
	case PTYPE_BOOL:
	case PTYPE_UINT32:
	case PTYPE_ENUM:
		for (i=0;i<n;i++) {
			_pbcA_index(p->data, i, var);
			_expand_message(m,10);
			m->ptr += _pbcV_encode32(var->integer.low , m->ptr);
		}
		break;
	case PTYPE_SINT32:
		for (i=0;i<n;i++) {
			_pbcA_index(p->data, i, var);
			_expand_message(m,10);
			m->ptr += _pbcV_zigzag32(var->integer.low, m->ptr);
		}
		break;
	case PTYPE_SINT64:
		for (i=0;i<n;i++) {
			_pbcA_index(p->data, i, var);
			_expand_message(m,10);
			m->ptr += _pbcV_zigzag((uint64_t)var->integer.low | (uint64_t)var->integer.hi << 32 , m->ptr);
		}
		break;
	default:
		// error
		memset(m->ptr , 0 , n);
		m->ptr += n;
		m->type->env->lasterror = "wmessage type error when pack packed";
		break;
	}

	end_offset = m->ptr - m->buffer;
	end_len = end_offset - (offset + len_len);
	if (end_len != len) {
		uint8_t temp[10];
		int end_len_len = _pbcV_encode32(end_len, temp);
		if (end_len_len != len_len) {
			_expand_message(m, end_len_len);
			memmove(m->buffer + offset + end_len_len , 
				m->buffer + offset + len_len , 
				end_len);
			m->ptr +=  end_len_len - len_len;
		}
		memcpy(m->buffer + offset , temp, end_len_len);
	}
}

static void
_pack_packed(void *p, void *ud) {
	struct _packed *packed = (struct _packed *)p;
	struct pbc_wmessage * m = (struct pbc_wmessage *)ud;
	int id = packed->id << 3 | WT_LEND;
	_expand_message(m,10);
	m->ptr += _pbcV_encode32(id, m->ptr);
	switch(packed->ptype) {
	case PTYPE_DOUBLE:
	case PTYPE_FIXED64:
	case PTYPE_SFIXED64:
		_pack_packed_64(packed,m);
		break;
	case PTYPE_FLOAT:
	case PTYPE_FIXED32:
	case PTYPE_SFIXED32:
		_pack_packed_32(packed,m);
		break;
	default:
		_pack_packed_varint(packed,m);
		break;
	}
}

void * 
pbc_wmessage_buffer(struct pbc_wmessage *m, struct pbc_slice *slice) {
	int i;
	int n;
	struct pbc_slice s;
	pbc_var var;

	if (m->packed) {
		_pbcM_sp_foreach_ud(m->packed , _pack_packed, m);
	}
	
	n = pbc_array_size(m->sub);
	for (i=0;i<n;i++) {
		
		_pbcA_index(m->sub, i , var);
		
		pbc_wmessage_buffer((struct pbc_wmessage *)var->p[0] , &s);
		if (s.buffer) {
			struct _field * f = (struct _field *)var->p[1];
			int id = f->id << 3 | WT_LEND;
			_expand_message(m,20+s.len);
			m->ptr += _pbcV_encode32(id, m->ptr);
			m->ptr += _pbcV_encode32(s.len, m->ptr);
			memcpy(m->ptr, s.buffer, s.len);
			m->ptr += s.len;
		}
	}
	slice->buffer = m->buffer;
	slice->len = m->ptr - m->buffer;

	return m->buffer;
}

