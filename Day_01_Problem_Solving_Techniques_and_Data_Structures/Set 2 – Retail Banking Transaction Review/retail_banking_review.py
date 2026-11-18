import time
import random

# =====================================================================
# TASK 1: Binary Search vs Linear Search (100,000 Transaction IDs)
# =====================================================================

def linear_search_with_count(transactions, target_id):
    comparisons = 0
    for idx, tx in enumerate(transactions):
        comparisons += 1
        if tx['txId'] == target_id:
            return idx, comparisons
    return -1, comparisons

def binary_search_with_count(sorted_txs, target_id):
    low = 0
    high = len(sorted_txs) - 1
    comparisons = 0
    while low <= high:
        comparisons += 1
        mid = (low + high) // 2
        if sorted_txs[mid]['txId'] == target_id:
            return mid, comparisons
        elif sorted_txs[mid]['txId'] < target_id:
            low = mid + 1
        else:
            high = mid - 1
    return -1, comparisons

def run_task1_search():
    print("=== TASK 1: Search Analysis on 100,000 Transactions ===")
    txs = sorted([{'txId': i, 'amount': 100.0} for i in range(1, 100001)], key=lambda x: x['txId'])
    
    # Best Case (Target at middle for binary, first for linear)
    _, lin_best = linear_search_with_count(txs, 1)
    _, bin_best = binary_search_with_count(txs, 50000)
    
    # Worst Case (Target at end)
    _, lin_worst = linear_search_with_count(txs, 100000)
    _, bin_worst = binary_search_with_count(txs, 100000) # approx log2(100000) ≈ 17
    
    print(f"Linear Search - Best Case: {lin_best} comparison(s) | Worst Case: {lin_worst} comparison(s)")
    print(f"Binary Search - Best Case: {bin_best} comparison(s) | Worst Case: {bin_worst} comparison(s)\n")


# =====================================================================
# TASK 2: Insertion Sort vs Merge Sort & Stability Demonstration
# =====================================================================

def insertion_sort_stable(txs):
    """O(n^2) Insertion Sort. Preserves relative order of identical keys (Stable)."""
    a = txs.copy()
    for i in range(1, len(a)):
        key = a[i]
        j = i - 1
        while j >= 0 and a[j]['timestamp'] > key['timestamp']:
            a[j + 1] = a[j]
            j -= 1
        a[j + 1] = key
    return a

def merge_sort_stable(txs):
    """O(n log n) Merge Sort. Stable sorting algorithm."""
    if len(txs) <= 1:
        return txs
    mid = len(txs) // 2
    left = merge_sort_stable(txs[:mid])
    right = merge_sort_stable(txs[mid:])
    
    return merge(left, right)

def merge(left, right):
    result = []
    i = j = 0
    while i < len(left) and j < len(right):
        # Using >= ensures stability when timestamps match
        if left[i]['timestamp'] <= right[j]['timestamp']:
            result.append(left[i])
            i += 1
        else:
            result.append(right[j])
            j += 1
    result.extend(left[i:])
    result.extend(right[j:])
    return result

def run_task2_sorting():
    print("=== TASK 2: Statement Sorting & Stability ===")
    # Sample statement with identical timestamps to demonstrate stability
    statement = [
        {'txId': 101, 'merchant': 'Coffee Shop', 'timestamp': '10:00:15'},
        {'txId': 102, 'merchant': 'Grocery Store', 'timestamp': '09:30:00'},
        {'txId': 103, 'merchant': 'Bookstore',   'timestamp': '10:00:15'} # Same timestamp as 101
    ]
    sorted_stmt = insertion_sort_stable(statement)
    print("Sorted by Timestamp (Stability preserved - TxID 101 stays before TxID 103):")
    for s in sorted_stmt:
        print(f"  TxID: {s['txId']}, Time: {s['timestamp']}, Merchant: {s['merchant']}")
    print()


# =====================================================================
# TASK 3: Duplicate Posting Detection (Same account, amount, merchant in 60s)
# =====================================================================

def detect_bank_duplicates(transactions):
    """Detects duplicate card postings within 60 seconds using a tracking hash map."""
    seen = {}
    duplicates = []
    for tx in transactions:
        key = (tx['account'], tx['amount'], tx['merchant'])
        t = tx['time_sec']
        if key in seen and (t - seen[key]) <= 60:
            duplicates.append(tx)
        else:
            seen[key] = t
    return duplicates

def run_task3_duplicates():
    print("=== TASK 3: Duplicate Posting Detection ===")
    tx_stream = [
        {'txId': 1, 'account': 'ACC-901', 'amount': 1500.0, 'merchant': 'SuperMart', 'time_sec': 100},
        {'txId': 2, 'account': 'ACC-902', 'amount': 450.0,  'merchant': 'FuelStation', 'time_sec': 150},
        {'txId': 3, 'account': 'ACC-901', 'amount': 1500.0, 'merchant': 'SuperMart', 'time_sec': 130} # Duplicate within 30s
    ]
    dups = detect_bank_duplicates(tx_stream)
    print(f"Flagged {len(dups)} duplicate posting(s): {dups}\n")


# =====================================================================
# TASK 4: Custom Stack & Queue Without Library Collections
# =====================================================================

class BankQueue:
    def __init__(self):
        self.queue = []
    def enqueue(self, item):
        self.queue.append(item)
    def dequeue(self):
        return self.queue.pop(0) if self.queue else None

class BankStack:
    def __init__(self):
        self.stack = []
    def push(self, item):
        self.stack.append(item)
    def pop(self):
        return self.stack.pop() if self.stack else None

def run_task4_stack_queue():
    print("=== TASK 4: Manual Review Queue & Adjustment Stack ===")
    review_queue = BankQueue()
    review_queue.enqueue("Review Suspicious Tx #401")
    review_queue.enqueue("Review Over-limit Tx #402")
    
    adjustment_stack = BankStack()
    adjustment_stack.push("Applied Fee Reversal: -₹500")
    adjustment_stack.push("Applied Interest Adjustment: -₹120")
    
    print("Processing Queue:", review_queue.dequeue())
    print("Reversing Last Adjustment:", adjustment_stack.pop(), "\n")


# =====================================================================
# TASK 5: Divide-and-Conquer Min/Max vs Brute-Force Scan
# =====================================================================

def find_min_max_dc(amounts, low, high):
    """Divide and conquer approach to find min and max amounts."""
    if low == high:
        return amounts[low], amounts[low]
    if high == low + 1:
        return (min(amounts[low], amounts[high]), max(amounts[low], amounts[high]))
    
    mid = (low + high) // 2
    min1, max1 = find_min_max_dc(amounts, low, mid)
    min2, max2 = find_min_max_dc(amounts, mid + 1, high)
    
    return min(min1, min2), max(max1, max2)

def run_task5_divide_conquer():
    print("=== TASK 5: Divide-and-Conquer Min & Max ===")
    daily_amounts = [450.50, 1200.00, 55.25, 8999.99, 12.00, 3400.00]
    min_amt, max_amt = find_min_max_dc(daily_amounts, 0, len(daily_amounts) - 1)
    print(f"Daily Lowest Amount: ₹{min_amt} | Daily Highest Amount: ₹{max_amt}\n")


if __name__ == "__main__":
    run_task1_search()
    run_task2_sorting()
    run_task3_duplicates()
    run_task4_stack_queue()
    run_task5_divide_conquer()