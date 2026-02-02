📚 BACKEND TESTING FILES INDEX
================================

This directory contains a complete API testing suite for the Room Booking System backend.

## 📁 Files Overview

```
backend/
├── 🧪 TEST SCRIPTS
│   ├── test_backend.sh              [13 KB] Full comprehensive tests (23 tests)
│   └── quick_test.sh                [1 KB]  Quick verification (5 tests)
│
├── 📮 API TESTING TOOLS  
│   └── Bookify_API.postman_collection.json  [12 KB] Postman collection
│
├── 📖 DOCUMENTATION
│   ├── BACKEND_TESTING_SUMMARY.md   [9.3 KB] Quick reference guide
│   ├── TESTING_README.md            [9 KB]   Complete testing guide
│   └── API_TESTING.md               [6.8 KB] Endpoint documentation
│
└── 💻 APPLICATION FILES
    ├── cmd/main.go
    ├── internal/handlers/
    ├── internal/services/
    └── go.mod
```

## 🚀 Quick Start (Choose One)

### 🏃 FASTEST - Quick Test (5 tests, 1 sec)
```bash
bash quick_test.sh
```
✅ Health check, login, rooms, user registration

### 🎯 RECOMMENDED - Full Test Suite (23 tests, 5 secs)
```bash
bash test_backend.sh
```
✅ All endpoints, all scenarios, complete coverage

### 🎨 INTERACTIVE - Manual Testing with Postman
1. Import `Bookify_API.postman_collection.json`
2. Set `base_url = http://localhost:8080`
3. Click through requests manually
4. Tokens auto-extract

## 📊 What Gets Tested

| Category | Tests | Status |
|----------|-------|--------|
| Authentication | 3 | ✅ Working |
| Rooms | 5 | ✅ Working |
| Bookings | 4 | ⚠️ Partial |
| Calendar | 4 | ❌ Missing |
| Users | 5 | ❌ Missing |
| Utilities | 2 | ✅ Working |
| **TOTAL** | **23** | **43% Pass** |

## 🎯 Usage Guide

### 1️⃣ Start Backend
```bash
cd backend
go run cmd/main.go
# Wait for: "Listening and serving HTTP on :8080"
```

### 2️⃣ Run Tests
```bash
# Option A: Full tests
bash test_backend.sh

# Option B: Quick tests
bash quick_test.sh

# Option C: Manual with Postman
# Import Bookify_API.postman_collection.json
```

### 3️⃣ View Results
- ✅ Green = Passed
- ❌ Red = Failed  
- ⚠️ Warning = Not implemented
- Tokens displayed for manual use

## 📋 File Details

### test_backend.sh
**Purpose**: Comprehensive API testing suite  
**Tests**: 23 different scenarios  
**Runtime**: 5-10 seconds  
**Features**:
- Auth (login, register, roles)
- CRUD operations (rooms, bookings, users)
- Error handling
- Token extraction
- Pretty colored output

### quick_test.sh
**Purpose**: Fast verification for CI/CD  
**Tests**: 5 essential checks  
**Runtime**: 1-2 seconds  
**Features**:
- Health check
- Login validation
- Room count
- User registration
- Compact output

### Bookify_API.postman_collection.json
**Purpose**: Manual API testing in Postman  
**Requests**: 20+ endpoints  
**Features**:
- Auto token extraction
- Environment variables
- Request examples
- Organized in folders
- Pre-configured headers

### Documentation Files
- **TESTING_README.md** - How to run tests, examples, troubleshooting
- **API_TESTING.md** - Endpoint details, status, requirements
- **BACKEND_TESTING_SUMMARY.md** - Quick reference, setup guide

## ✅ Success Indicators

| Check | Command | Expected |
|-------|---------|----------|
| Backend Running | `ps aux \| grep "go run"` | Process listed |
| Server Responding | `curl localhost:8080/health` | `{"status":"ok"}` |
| Quick Test | `bash quick_test.sh` | No errors |
| Full Test | `bash test_backend.sh` | 10+ ✅ symbols |

## 🔧 Customization

### Add New Test
Edit `test_backend.sh` and add:
```bash
# Test X: Description
echo "X️⃣  TEST NAME"
echo "---"
RESPONSE=$(curl -s -X POST "$BASE_URL/endpoint" ...)
if echo "$RESPONSE" | grep -q "expected"; then
  success "Test passed"
else
  error "Test failed"
fi
echo ""
```

### Change Base URL
Edit `test_backend.sh` or `quick_test.sh`:
```bash
BASE_URL="http://your-domain.com:8080"
```

### Adjust Postman Collection
1. Import in Postman
2. Edit collection variables
3. Save locally or export

## 🐛 Troubleshooting

### Tests Won't Run
```bash
# Make scripts executable
chmod +x test_backend.sh quick_test.sh

# Check bash is installed
which bash
```

### Backend Connection Issues
```bash
# Check if running
curl -v http://localhost:8080/health

# Check if port is open
lsof -i :8080

# Try different port
BASE_URL="http://localhost:3000" bash quick_test.sh
```

### Postman Can't Connect
1. Make sure backend is running
2. Check base_url variable
3. Disable any proxies
4. Try cURL first: `curl http://localhost:8080/health`

## 📊 Test Coverage

```
✅ Implemented & Working (10)
  • Health check
  • Login/Auth
  • Room CRUD
  • User registration
  • Role-based access

⚠️ Partially Working (6)
  • Booking operations
  • Missing endpoints

❌ Not Implemented (7)
  • Calendar integration
  • User management
  • Advanced bookings
```

## 🎓 Learning Resources

### Learn by Examples
1. **Read test_backend.sh** - See all curl examples
2. **Import Postman** - GUI examples with syntax highlighting
3. **Study cURL** - Learn HTTP fundamentals
4. **Check API_TESTING.md** - Endpoint reference

### API Endpoints
- Auth: `/auth/login`, `/auth/register`
- Rooms: `/rooms`, `/rooms/:id`
- Bookings: `/bookings`, `/bookings/:id`
- Health: `/health`

## 🚀 Next Steps

1. ✅ Run tests to see current status
2. ⚠️ Fix failing endpoints if needed
3. 📊 Integrate into CI/CD pipeline
4. 📈 Add more test scenarios
5. 🔒 Test security edge cases

## 💾 Backup & Version Control

### Save Test Results
```bash
bash test_backend.sh > results_$(date +%Y%m%d_%H%M%S).txt
```

### Version Control
```bash
git add backend/test_backend.sh
git add backend/quick_test.sh
git add backend/Bookify_API.postman_collection.json
git add backend/*_TESTING*.md
git add backend/API_TESTING.md
git commit -m "Add comprehensive backend testing suite"
```

## 📞 Support

### Quick Help
```bash
# Show this file
cat backend/FILES_INDEX.md

# Run quick test
bash quick_test.sh

# Read full guide
cat backend/TESTING_README.md

# See endpoint docs
cat backend/API_TESTING.md
```

### Common Commands
```bash
# Test specific endpoint
curl -X GET http://localhost:8080/rooms | jq '.'

# Test with authentication
curl -H "Authorization: Bearer TOKEN" http://localhost:8080/bookings

# Pretty print JSON response
curl http://localhost:8080/rooms | jq '.data[] | {id, name}'
```

---

## 📈 Statistics

- **Total Tests**: 23
- **Passing**: 10 (43%)
- **Partial**: 6 (26%)
- **Missing**: 7 (31%)
- **Lines of Code**: ~500 (test scripts)
- **Documentation**: ~35 KB
- **Setup Time**: < 1 minute

---

## 🎯 Testing Workflow

```
┌─────────────────────┐
│  Start Backend      │
│  go run main.go     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Choose Test Method │
├─────────────────────┤
│ • Quick Test        │
│ • Full Suite        │
│ • Postman Manual    │
│ • cURL Commands     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Run Tests          │
│  bash test_...sh    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Review Results     │
│  ✅ ❌ ⚠️          │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Fix Issues         │
│  (if any)           │
└─────────────────────┘
```

---

**Last Updated**: January 15, 2026  
**Maintainer**: Backend Testing Suite  
**Version**: 1.0  
**Status**: ✅ Ready for Use
