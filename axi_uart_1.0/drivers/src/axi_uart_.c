#include "axi_uart_sys_.h"

status axi_uart_init(axi_uart_handle *p_handle, axi_uart_inition *init) {
    return init_driver_(p_handle, init, true_);
}

static inline status init_driver_(axi_uart_handle *p_handle, axi_uart_inition *init, boolean do_init) {
	p_handle->ready = false_;
	p_handle->init  = un_init_;

	if ((null_ == p_handle) || (null_ == init)) {
        return error_;
	}

	set_stop_bits((axi_uart_regs* )p_handle->id, init->stop_bits, do_init);
	//set_parity_type ((ps_uart_regs* )p_handle->id, init->parity_type, do_init);
	set_data_bits   ((axi_uart_regs* )p_handle->id, init->data_bits, do_init);
	set_baud_rate   ((axi_uart_regs* )p_handle->id, init->baud_rate, do_init);

	if (true_ == do_init) {
	   p_handle->init = ok_;
	   p_handle->ready = true_;
	}

	return ok_;
}

status axi_uart_reinit(axi_uart_handle *p_handle, axi_uart_inition *init) {
	if (ok_ != p_handle->init) {
		return p_handle->init;
	}

	return init_driver_(p_handle, init, true_);
}

status axi_uart_release(axi_uart_handle *p_handle) {
	if (ok_ != p_handle->init) {
			return p_handle->init;
	}

	axi_uart_inition init = {};

	return init_driver_(p_handle, &init, false_);
}

status axi_uart_write_data(axi_uart_handle *p_handle, char *p_data, size_t size) {
	axi_uart_regs *p_uart_regs = null_;

	if ((null_ == p_handle) || (null_ == p_data) || (0 == size)) {
		return error_;
	}

	if (ok_ != p_handle->init) {
		return p_handle->init;
	}

	p_handle->ready = false_;

	p_uart_regs = (axi_uart_regs* )p_handle->id;

	if (true_ == p_handle->do_unblocking_mode) {

	}
	else {
		write_block_mode_data_(p_uart_regs, p_data, size);
		p_handle->ready = true_;
	}

	return ok_;
}

static inline void write_block_mode_data_(axi_uart_regs *p_uart_regs, char *p_data, size_t size) {
	uint32_t i = 0;

	for(i = 0; i < size; i++) {
		set_data_word_(p_uart_regs , p_data[i]);
		set_tx_enable_(p_uart_regs, true_);
	    while(AXI_UART_TX_TRNS_COMPLETE != get_status_(p_uart_regs));
	}
}

//---------------------------------------------lower half---------------------------------------------//

static inline void set_stop_bits(axi_uart_regs *p_reg_base, axi_uart_stop_bits stop_bits, boolean do_setting) {
	p_reg_base->control &= ~(TRUE << AXI_UART_STOP_NUM_BIT_OFFSET);

	if (true_ == do_setting) {
		p_reg_base->control |= (stop_bits << AXI_UART_STOP_NUM_BIT_OFFSET);
	}
	else {
		p_reg_base->control |= (AXI_UART_CONTROL_REG_RST_VAL & AXI_UART_STOP_NUM_BIT_MASK);
	}
}

static inline void set_data_bits(axi_uart_regs *p_reg_base, axi_uart_data_bits data_bits, boolean do_setting) {
	p_reg_base->control &= ~(TRUE << AXI_UART_DATA_NUM_BIT_OFFSET);

	if (true_ == do_setting) {
		p_reg_base->control |= (data_bits << AXI_UART_DATA_NUM_BIT_OFFSET);
	}
	else {
		p_reg_base->control |= (AXI_UART_CONTROL_REG_RST_VAL & AXI_UART_DATA_NUM_BIT_MASK);
	}
}

static inline void set_baud_rate(axi_uart_regs *p_reg_base, uint32_t baud_rate, boolean do_setting) {
	p_reg_base->baud_rate = AXI_UART_BAUD_REG_RST_VAL;

	if (true_ == do_setting) {
		p_reg_base->baud_rate = baud_rate;
	}
}

static inline void set_tx_enable_(axi_uart_regs *p_reg_base, boolean do_setting) {
	p_reg_base->control &= ~(TRUE << AXI_UART_TX_EN_BIT_OFFSET);

	if (true_ == do_setting) {
		p_reg_base->control |= (TRUE << AXI_UART_TX_EN_BIT_OFFSET);
	}
	else {
		p_reg_base->control |= (AXI_UART_CONTROL_REG_RST_VAL & AXI_UART_TX_EN_BIT_MASK);
	}
}

//status pre or after?
static inline void set_data_word_(axi_uart_regs *p_reg_base, char data) {
	p_reg_base->tx_data = data;
}

static inline uint32_t get_status_(axi_uart_regs *p_reg_base) {
	return p_reg_base->status;
}
