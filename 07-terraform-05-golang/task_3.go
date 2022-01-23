package main

import (
	"fmt"
)

const foot = 0.3048

func main() {
	fmt.Print("Enter a length in meters: ")
	var input float64
	fmt.Scanf("%f", &input)

	output := input / foot

	fmt.Printf("Foots: %.2f \n", output)

	// ========================

	elems := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}
	smallest := find_smallest_element(elems)
	fmt.Println("Smallest element is: ", smallest)

	// ========================

	fmt.Println("Tripples: ", tripple_number())
}

func find_smallest_element(elements []int) int {
	smallest := elements[0]

	for _, num := range elements[1:] {
		if num < smallest {
			smallest = num
		}
	}
	return smallest
}

func tripple_number() []int {
	var result []int

	for i := 1; i <= 100; i++ {
		if i%3 == 0 {
			result = append(result, i)
		}
	}

	return result
}
