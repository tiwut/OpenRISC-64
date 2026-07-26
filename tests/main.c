int main() {
    int a = 15;
    int b = 25;
    
    // Perform some basic operations to verify C compilation and execution
    int c = a + b;
    int d = c * 2; // Notice we didn't implement M extension (Multiply), gcc will use software multiplication or shift! 
                   // Let's stick to base operations that RV64I supports.
    int e = c << 1; 
    
    return e;
}
