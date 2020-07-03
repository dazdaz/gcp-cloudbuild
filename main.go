package main

import (
	"fmt"
	"time"
)

func main() {
	for true {
		fmt.Println("Hello, 1")
		time.Sleep(2 * time.Second)
	}
}
