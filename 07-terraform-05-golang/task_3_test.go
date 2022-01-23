package main

import (
	"testing"
)

func TestFindSmallestElement(t *testing.T) {
	x := []int{3, 2, 55}
	v := findSmallestElement(x)
	if v != 2 {
		t.Error("Expected 3, got ", v)
	}
}

func TestTrippleNumber(t *testing.T) {
	result := trippleNumber()

	for _, e := range result {
		if e%3 != 0 {
			t.Error("Expected be % 3, got ", e)
		}
	}
}
