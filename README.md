# UART-FIFO

UART transmitter and receiver integrated with a synchronous FIFO using Verilog HDL.

## Overview

This project implements a UART communication system with a synchronous FIFO buffer.

The UART receiver accepts serial data and stores the received bytes in the FIFO. The stored data can then be read and transmitted through the UART transmitter.

## Features

- UART transmitter
- UART receiver
- Synchronous FIFO
- UART-FIFO integration
- Parameterized clock and baud-rate configuration
- Verilog HDL RTL design
- Simulation-based verification

## Project Structure

```text
uart-fifo/
├── rtl/
│   ├── uart_tx.v
│   ├── uart_rx.v
│   ├── fifo.v
│   └── uart_fifo_top.v
│
├── tb/
│   └── uart_fifo_tb.v
│
└── README.md
