from collections import deque, defaultdict

# =====================================================================
# TASK 1: BST of Hub Codes, Height Calculation & Sorted Input Effect
# =====================================================================

class HubBSTNode:
    def __init__(self, code):
        self.code = code
        self.left = None
        self.right = None

class HubBST:
    def __init__(self):
        self.root = None

    def insert(self, code):
        if not self.root:
            self.root = HubBSTNode(code)
        else:
            self._insert_recursive(self.root, code)

    def _insert_recursive(self, node, code):
        if code < node.code:
            if node.left is None:
                node.left = HubBSTNode(code)
            else:
                self._insert_recursive(node.left, code)
        elif code > node.code:
            if node.right is None:
                node.right = HubBSTNode(code)
            else:
                self._insert_recursive(node.right, code)

    def search(self, code):
        return self._search_recursive(self.root, code)

    def _search_recursive(self, node, code):
        if not node or node.code == code:
            return node
        if code < node.code:
            return self._search_recursive(node.left, code)
        return self._search_recursive(node.right, code)

    def get_height(self, node):
        if not node:
            return -1
        return 1 + max(self.get_height(node.left), self.get_height(node.right))

def run_task1():
    print("=== TASK 1: Hub Code BST & Height Analysis ===")
    bst = HubBST()
    # Balanced insertion order
    hub_codes = ["MUM", "DEL", "BLR", "CHN", "HYD", "KOL", "AMD", "PUN"]
    for code in hub_codes:
        bst.insert(code)
    
    height = bst.get_height(bst.root)
    print(f"Inserted hubs: {hub_codes}")
    print(f"Height of the BST: {height}")
    print("Effect of Sorted Input: If hub codes are inserted in strictly sorted order (e.g., AMD, BLR, CHN...), "
          "the BST degenerates into a linear linked list (skewed tree), making the height O(n) and search O(n) instead of O(log n).\n")


# =====================================================================
# TASK 2: Parcel Tracking Hash Map & Double Scan Detection
# =====================================================================

def detect_double_scans(scan_events):
    """
    Detects parcels scanned twice at the same hub using a hash map tracking (parcel_id, hub_id).
    """
    scanned_locations = set()
    double_scans = []
    
    for scan in scan_events:
        parcel_id = scan['parcel_id']
        hub_id = scan['hub_id']
        key = (parcel_id, hub_id)
        
        if key in scanned_locations:
            double_scans.append(scan)
        else:
            scanned_locations.add(key)
            
    return double_scans

def run_task2():
    print("=== TASK 2: Parcel Tracking & Double Scan Detection ===")
    scans = [
        {'parcel_id': 'TRK-001', 'hub_id': 'MUM'},
        {'parcel_id': 'TRK-002', 'hub_id': 'DEL'},
        {'parcel_id': 'TRK-001', 'hub_id': 'MUM'}  # Double scanned at same hub
    ]
    dups = detect_double_scans(scans)
    print(f"Flagged double-scanned parcels: {dups}\n")


# =====================================================================
# TASK 3: Network Graph, BFS Shortest Hops & DFS Reachability
# =====================================================================

class LogisticsNetwork:
    def __init__(self):
        self.adj_list = defaultdict(list)

    def add_route(self, u, v):
        self.adj_list[u].append(v)
        self.adj_list[v].append(u) # Bidirectional network

    def shortest_path_bfs(self, start, target):
        """Finds route with fewest hops between two hubs using BFS."""
        if start == target:
            return [start]
        queue = deque([[start]])
        visited = {start}
        
        while queue:
            path = queue.popleft()
            node = path[-1]
            if node == target:
                return path
            for neighbor in self.adj_list[node]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(path + [neighbor])
        return []

    def reachable_hubs_dfs(self, start):
        """Lists every hub reachable from central depot using DFS."""
        visited = set()
        
        def dfs(node):
            visited.add(node)
            for neighbor in self.adj_list[node]:
                if neighbor not in visited:
                    dfs(neighbor)
                    
        dfs(start)
        return list(visited)

def run_task3():
    print("=== TASK 3: National Logistics Network Graph (BFS & DFS) ===")
    net = LogisticsNetwork()
    # 10 Hubs routing network
    net.add_route("DEL", "MUM")
    net.add_route("DEL", "BLR")
    net.add_route("MUM", "PUN")
    net.add_route("BLR", "CHN")
    net.add_route("CHN", "HYD")
    net.add_route("HYD", "KOL")
    net.add_route("KOL", "AMD")
    net.add_route("AMD", "JAI")
    net.add_route("JAI", "DEL")
    
    print("Adjacency List representation:")
    for hub, neighbors in net.adj_list.items():
        print(f"  {hub} -> {neighbors}")
        
    shortest = net.shortest_path_bfs("DEL", "CHN")
    print(f"\nFewest hops route from DEL to CHN (BFS): {shortest} ({len(shortest)-1} hops)")
    
    reachable = net.reachable_hubs_dfs("DEL")
    print(f"All hubs reachable from central depot DEL (DFS): {reachable}\n")


# =====================================================================
# TASK 4: 4-Hour Window with Highest Average (Sliding Window)
# =====================================================================

def highest_average_4h_window(hourly_counts):
    """Finds 4-hour window with highest average parcel count using sliding window."""
    k = 4
    if len(hourly_counts) < k:
        return 0, 0.0
    
    current_sum = sum(hourly_counts[:k])
    max_sum = current_sum
    best_start = 0
    
    for i in range(k, len(hourly_counts)):
        current_sum = current_sum - hourly_counts[i - k] + hourly_counts[i]
        if current_sum > max_sum:
            max_sum = current_sum
            best_start = i - k + 1
            
    return best_start, max_sum / k

def run_task4():
    print("=== TASK 4: Sliding Window (Highest Average 4-Hour Window) ===")
    hourly_parcels = [1200, 1500, 1800, 2200, 2500, 2400, 2100, 1900]
    start_hr, avg_count = highest_average_4h_window(hourly_parcels)
    print(f"Hourly Counts: {hourly_parcels}")
    print(f"Busiest 4-Hour Window starts at Hour {start_hr} with highest average: {avg_count:.2f} parcels/hr\n")


# =====================================================================
# TASK 5: Two-Pointer Route Palindrome Checker
# =====================================================================

def is_route_palindrome(route_str):
    """Checks if a route code string is a palindrome, ignoring case and separators."""
    cleaned = "".join(c.lower() for c in route_str if c.isalnum())
    left, right = 0, len(cleaned) - 1
    
    while left < right:
        if cleaned[left] != cleaned[right]:
            return False
        left += 1
        right -= 1
    return True

def run_task5():
    print("=== TASK 5: Two-Pointer Route Palindrome Checker ===")
    test_route = "MUM-DEL-BLR-DEL-MUM"
    result = is_route_palindrome(test_route)
    print(f"Route Code: '{test_route}'")
    print(f"Is Palindrome route: {result}\n")


if __name__ == "__main__":
    run_task1()
    run_task2()
    run_task3()
    run_task4()
    run_task5()