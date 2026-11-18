import time
import random
from collections import deque

# =====================================================================
# TASK 1: Linear Search vs Binary Search on 50,000 Records
# =====================================================================

def linear_search(orders, target_id):
    """Performs linear search over an unsorted or sorted list. O(n) time."""
    for idx, order in enumerate(orders):
        if order['orderId'] == target_id:
            return idx
    return -1

def binary_search(orders_sorted, target_id):
    """Performs binary search over a sorted list by orderId. O(log n) time."""
    low = 0
    high = len(orders_sorted) - 1
    while low <= high:
        mid = (low + high) // 2
        if orders_sorted[mid]['orderId'] == target_id:
            return mid
        elif orders_sorted[mid]['orderId'] < target_id:
            low = mid + 1
        else:
            high = mid - 1
    return -1

def benchmark_search():
    print("--- TASK 1: Search Benchmarking (50,000 Records) ---")
    orders = [
        {
            'orderId': i,
            'customerId': random.randint(1000, 9999),
            'amount': round(random.uniform(100, 50000), 2),
            'createdAt': f"2026-11-18 10:{random.randint(0,59):02d}:{random.randint(0,59):02d}"
        }
        for i in range(1, 50001)
    ]
    
    # Target near the end to stress linear search
    target = 48500
    
    # Linear Search Benchmark
    start_time = time.perf_counter()
    lin_idx = linear_search(orders, target)
    lin_time = (time.perf_counter() - start_time) * 1000
    
    # Binary Search Benchmark (requires sorted data)
    orders_sorted = sorted(orders, key=lambda x: x['orderId'])
    start_time = time.perf_counter()
    bin_idx = binary_search(orders_sorted, target)
    bin_time = (time.perf_counter() - start_time) * 1000
    
    print(f"Linear Search: Found at index {lin_idx} in {lin_time:.4f} ms")
    print(f"Binary Search: Found at index {bin_idx} in {bin_time:.4f} ms\n")


# =====================================================================
# TASK 2: O(n²) Bubble Sort & O(n log n) Merge Sort vs Built-in Sort
# =====================================================================

def bubble_sort_desc(arr):
    """O(n^2) sorting algorithm ranking orders by amount descending."""
    n = len(arr)
    # Trace first 3 passes for demonstration
    passes_tracked = 0
    a = arr.copy()
    for i in range(n - 1):
        swapped = False
        for j in range(0, n - i - 1):
            if a[j]['amount'] < a[j + 1]['amount']:
                a[j], a[j + 1] = a[j + 1], a[j]
                swapped = True
        passes_tracked += 1
        if passes_tracked <= 3:
            print(f"Bubble Sort - Pass {passes_tracked} complete. Top amount: {a[0]['amount']}")
        if not swapped:
            break
        if passes_tracked >= 3:
            break
    return a

def merge_sort_desc(arr):
    """O(n log n) Merge Sort sorting orders by amount descending."""
    if len(arr) <= 1:
        return arr
    
    mid = len(arr) // 2
    left = merge_sort_desc(arr[:mid])
    right = merge_sort_desc(arr[mid:])
    
    return merge(left, right)

def merge(left, right):
    result = []
    i = j = 0
    while i < len(left) and j < len(right):
        if left[i]['amount'] >= right[j]['amount']:
            result.append(left[i])
            i += 1
        else:
            result.append(right[j])
            j += 1
    result.extend(left[i:])
    result.extend(right[j:])
    return result

def benchmark_sorting():
    print("--- TASK 2: Sorting Comparison (10,000 Records) ---")
    sample_data = [
        {'orderId': i, 'amount': round(random.uniform(50, 10000), 2)}
        for i in range(1, 10001)
    ]
    
    # Trace Bubble Sort first 3 passes on a smaller slice
    print("Tracing Bubble Sort (first 3 passes):")
    bubble_sort_desc(sample_data[:500])
    
    # Benchmark Merge Sort on 10,000 records
    start = time.perf_counter()
    _ = merge_sort_desc(sample_data)
    merge_time = (time.perf_counter() - start) * 1000
    
    # Benchmark Built-in Timsort (sorted()) on 10,000 records
    start = time.perf_counter()
    _ = sorted(sample_data, key=lambda x: x['amount'], reverse=True)
    builtin_time = (time.perf_counter() - start) * 1000
    
    print(f"Merge Sort (O(n log n)) Time: {merge_time:.2f} ms")
    print(f"Built-in Timsort Time: {builtin_time:.2f} ms\n")


# =====================================================================
# TASK 3: Duplicate Order Detection Using Hash-Based Structure
# =====================================================================

def detect_duplicates(orders):
    """Detects orders with same customerId and createdAt minute using a hash set. O(n) time."""
    seen = set()
    duplicates = []
    for order in orders:
        # Extract timestamp down to the minute (YYYY-MM-DD HH:MM)
        minute_key = (order['customerId'], order['createdAt'][:16])
        if minute_key in seen:
            duplicates.append(order)
        else:
            seen.add(minute_key)
    return duplicates

def run_duplicate_detection():
    print("--- TASK 3: Duplicate Order Detection ---")
    orders = [
        {'orderId': 101, 'customerId': 501, 'amount': 1500.0, 'createdAt': '2026-11-18 10:15:22'},
        {'orderId': 102, 'customerId': 502, 'amount': 2300.0, 'createdAt': '2026-11-18 10:15:45'},
        {'orderId': 103, 'customerId': 501, 'amount': 1500.0, 'createdAt': '2026-11-18 10:15:50'} # Duplicate minute & customer
    ]
    dups = detect_duplicates(orders)
    print(f"Detected {len(dups)} duplicate submission(s): {dups}\n")


# =====================================================================
# TASK 4: Custom Stack & Queue vs Built-in Equivalents
# =====================================================================

class CustomStack:
    def __init__(self):
        self.items = []
    def push(self, item):
        self.items.append(item)
    def pop(self):
        return self.items.pop() if self.items else None
    def peek(self):
        return self.items[-1] if self.items else None

class CustomQueue:
    def __init__(self):
        self.items = []
    enqueue = lambda self, item: self.items.append(item)
    def dequeue(self):
        return self.items.pop(0) if self.items else None # O(n) shift in plain list

def run_stack_queue_demo():
    print("--- TASK 4: Stack & Queue Simulation ---")
    # Stack for Undo Edit
    undo_stack = CustomStack()
    undo_stack.push("Edit Order #101: Amount changed to ₹2,500")
    undo_stack.push("Edit Order #101: Shipping address updated")
    print("Last action undone:", undo_stack.pop())
    
    # Queue for Dispatch Line (using collections.deque for O(1) performance)
    dispatch_queue = deque(["Order #101", "Order #102", "Order #103"])
    dispatch_queue.append("Order #104")
    print("Dispatched:", dispatch_queue.popleft())
    print("Next in dispatch line:", dispatch_queue[0], "\n")


# =====================================================================
# TASK 5: Greedy Refund vs Dynamic Programming
# =====================================================================

def greedy_refund(amount, denominations):
    """Greedy approach for coin change."""
    result = []
    for coin in sorted(denominations, reverse=True):
        while amount >= coin:
            amount -= coin
            result.append(coin)
    return result

def dp_coin_change(coins, target):
    """Dynamic programming approach guaranteed to find minimum coins."""
    dp = [float('inf')] * (target + 1)
    dp[0] = 0
    parent = [-1] * (target + 1)
    
    for i in range(1, target + 1):
        for c in coins:
            if i - c >= 0 and dp[i - c] + 1 < dp[i]:
                dp[i] = dp[i - c] + 1
                parent[i] = c
                
    if dp[target] == float('inf'):
        return []
    
    # Reconstruct path
    curr = target
    coins_used = []
    while curr > 0:
        c = parent[curr]
        coins_used.append(c)
        curr -= c
    return coins_used

def run_refund_demo():
    print("--- TASK 5: Refund Calculation (Greedy vs DP) ---")
    # Standard Indian currency denominations where greedy always works
    standard_notes = [500, 200, 100, 50, 20, 10]
    print(f"Greedy refund for ₹780 using standard notes: {greedy_refund(780, standard_notes)}")
    
    # Failure case: Denominations [1, 4, 6], Target = 8
    # Greedy picks 6 -> remaining 2 -> 1, 1 (Total 3 coins).
    # Optimal DP picks 4, 4 (Total 2 coins).
    faulty_denoms = [1, 4, 6]
    target = 8
    print(f"Greedy for target {target} with {faulty_denoms}: {greedy_refund(target, faulty_denoms)}")
    print(f"DP Optimal for target {target} with {faulty_denoms}: {dp_coin_change(faulty_denoms, target)}\n")


if __name__ == "__main__":
    benchmark_search()
    benchmark_sorting()
    run_duplicate_detection()
    run_stack_queue_demo()
    run_refund_demo()