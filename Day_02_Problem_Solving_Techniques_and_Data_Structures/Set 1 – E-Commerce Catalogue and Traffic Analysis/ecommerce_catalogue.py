import time
import random
from collections import deque, defaultdict

# =====================================================================
# TASK 1: Binary Search Tree of Product Categories & Traversals
# =====================================================================

class BSTNode:
    def __init__(self, key, name):
        self.key = key
        self.name = name
        self.left = None
        self.right = None

class CategoryBST:
    def __init__(self):
        self.root = None

    def insert(self, key, name):
        if not self.root:
            self.root = BSTNode(key, name)
        else:
            self._insert_recursive(self.root, key, name)

    def _insert_recursive(self, node, key, name):
        if key < node.key:
            if node.left is None:
                node.left = BSTNode(key, name)
            else:
                self._insert_recursive(node.left, key, name)
        elif key > node.key:
            if node.right is None:
                node.right = BSTNode(key, name)
            else:
                self._insert_recursive(node.right, key, name)

    def search(self, key):
        return self._search_recursive(self.root, key)

    def _search_recursive(self, node, key):
        if not node or node.key == key:
            return node
        if key < node.key:
            return self._search_recursive(node.left, key)
        return self._search_recursive(node.right, key)

    def inorder(self, node, res):
        if node:
            self.inorder(node.left, res)
            res.append(node.name)
            self.inorder(node.right, res)

    def preorder(self, node, res):
        if node:
            res.append(node.name)
            self.preorder(node.left, res)
            self.preorder(node.right, res)

    def postorder(self, node, res):
        if node:
            self.postorder(node.left, res)
            self.postorder(node.right, res)
            res.append(node.name)

def run_task1():
    print("=== TASK 1: BST Category Catalogue ===")
    bst = CategoryBST()
    categories = [
        (50, "Electronics"), (30, "Books"), (70, "Home & Kitchen"),
        (20, "Apparel"), (40, "Beauty"), (60, "Sports"), (80, "Toys"),
        (10, "Grocery"), (25, "Footwear"), (35, "Jewellery"), (45, "Stationery"),
        (55, "Automotive"), (65, "Furniture"), (75, "Gardening"), (85, "Pet Supplies")
    ]
    for key, name in categories:
        bst.insert(key, name)
    
    in_res, pre_res, post_res = [], [], []
    bst.inorder(bst.root, in_res)
    bst.preorder(bst.root, pre_res)
    bst.postorder(bst.root, post_res)
    
    print(f"Inorder Traversal: {in_res[:5]} ... (Total: {len(in_res)})")
    print(f"Preorder Traversal: {pre_res[:5]} ...")
    print(f"Postorder Traversal: {post_res[:5]} ...\n")


# =====================================================================
# TASK 2: Hash Table with Chaining vs Built-in dict (SKU Look-up)
# =====================================================================

class ChainingHashTable:
    def __init__(self, size=10):
        self.size = size
        self.table = [[] for _ in range(size)]

    def _hash(self, key):
        return hash(key) % self.size

    def insert(self, key, value):
        idx = self._hash(key)
        for pair in self.table[idx]:
            if pair[0] == key:
                pair[1] = value
                return
        self.table[idx].append([key, value])

    def get(self, key):
        idx = self._hash(key)
        for pair in self.table[idx]:
            if pair[0] == key:
                return pair[1]
        return None

def run_task2():
    print("=== TASK 2: Hash Table with Chaining & Built-in Dict Benchmark ===")
    ht = ChainingHashTable(size=5)
    # Demonstrating collision intentionally with keys hashing to same bucket
    ht.insert("SKU-100", "Laptop")
    ht.insert("SKU-105", "Phone") # Collision in size 5 table (100 % 5 == 0, 105 % 5 == 0)
    print(f"Bucket 0 (Chaining collision demo): {ht.table[0]}")
    
    # Benchmark 100,000 SKUs: Custom vs Built-in dict
    skus = [(f"SKU-{i}", f"Product-{i}") for i in range(100000)]
    
    # Built-in dict benchmark
    builtin_dict = {}
    start = time.perf_counter()
    for k, v in skus:
        builtin_dict[k] = v
    for i in range(10000):
        _ = builtin_dict.get(f"SKU-{random.randint(0, 99999)}")
    builtin_time = (time.perf_counter() - start) * 1000
    
    print(f"Built-in dict (100k insertions + 10k lookups): {builtin_time:.2f} ms\n")


# =====================================================================
# TASK 3: Microservice Deployment Dependencies & Cycle Detection (Graph)
# =====================================================================

class DependencyGraph:
    def __init__(self):
        self.graph = defaultdict(list)
        self.nodes = set()

    def add_edge(self, u, v):
        self.graph[u].append(v)
        self.nodes.add(u)
        self.nodes.add(v)

    def topological_sort_dfs(self):
        visited = set()
        stack = []
        rec_stack = set()

        def dfs(node):
            visited.add(node)
            rec_stack.add(node)
            for neighbor in self.graph[node]:
                if neighbor not in visited:
                    if dfs(neighbor):
                        return True
                elif neighbor in rec_stack:
                    return True # Cycle detected
            rec_stack.remove(node)
            stack.append(node)
            return False

        for node in list(self.nodes):
            if node not in visited:
                if dfs(node):
                    return "Circular Dependency Detected!"
        return stack[::-1]

def run_task3():
    print("=== TASK 3: Microservice Deployment Graph & Cycle Detection ===")
    dag = DependencyGraph()
    dag.add_edge("database", "backend")
    dag.add_edge("backend", "pricing")
    dag.add_edge("pricing", "cart")
    dag.add_edge("inventory", "cart")
    
    order = dag.topological_sort_dfs()
    print(f"Valid Deployment Order (BFS/DFS Topological Sort): {order}")
    
    # Test Circular Dependency
    cyclic_dag = DependencyGraph()
    cyclic_dag.add_edge("cart", "pricing")
    cyclic_dag.add_edge("pricing", "cart")
    print(f"Cyclic Dependency Check: {cyclic_dag.topological_sort_dfs()}\n")


# =====================================================================
# TASK 4: Busiest Continuous 3-Hour Window (Sliding Window)
# =====================================================================

def find_busiest_window(rpm_24h):
    """Finds busiest continuous 3-hour window (180 minutes or 3 hourly blocks)."""
    k = 3 # 3 hours
    max_sum = sum(rpm_24h[:k])
    window_sum = max_sum
    best_start = 0
    
    for i in range(k, len(rpm_24h)):
        window_sum = window_sum - rpm_24h[i - k] + rpm_24h[i]
        if window_sum > max_sum:
            max_sum = window_sum
            best_start = i - k + 1
            
    return best_start, max_sum

def run_task4():
    print("=== TASK 4: Sliding Window (Busiest 3-Hour Traffic Window) ===")
    # 24 hourly traffic requests
    rpm_24h = [1200, 900, 800, 750, 1100, 2500, 4200, 5100, 
               4800, 4600, 4900, 5300, 5500, 5200, 4700, 4600, 
               5800, 6200, 5900, 5100, 4300, 3200, 2100, 1500]
    start_hr, peak_load = find_busiest_window(rpm_24h)
    print(f"Busiest 3-Hour Window starts at Hour {start_hr}:00 with total load {peak_load} reqs\n")


# =====================================================================
# TASK 5: Two-Pointer Pattern for Gift-Card Value Pairs
# =====================================================================

def find_pairs_with_sum(sorted_orders, target):
    left = 0
    right = len(sorted_orders) - 1
    pairs = []
    while left < right:
        current_sum = sorted_orders[left] + sorted_orders[right]
        if current_sum == target:
            pairs.append((sorted_orders[left], sorted_orders[right]))
            left += 1
            right -= 1
        elif current_sum < target:
            left += 1
        else:
            right -= 1
    return pairs

def run_task5():
    print("=== TASK 5: Two-Pointer Gift-Card Pair Matcher ===")
    order_values = [150, 200, 350, 400, 500, 650, 800, 1000] # Sorted
    gift_card_target = 1000
    matched_pairs = find_pairs_with_sum(order_values, gift_card_target)
    print(f"Sorted Orders: {order_values}")
    print(f"Target Gift Card Value: ₹{gift_card_target}")
    print(f"Matching Pairs Found: {matched_pairs}\n")


if __name__ == "__main__":
    run_task1()
    run_task2()
    run_task3()
    run_task4()
    run_task5()