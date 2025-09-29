## [1.0.0] - 2025-09-22

### Added
- Paystack integration for all platforms (Android, iOS, Web, Linux, macOS, Windows)
- New API methods for payment processing
- Support for multiple payment methods including card payments, bank transfers, and mobile money

### Changed
- Breaking changes: API stabilization and method signatures updated for production readiness

## [1.1.0] - 2025-09-29

### Added
- **Comprehensive Testing Suite**: Added extensive unit, integration, and widget tests
- **CI/CD Pipeline**: GitHub Actions workflow for automated testing across all platforms
- **Performance Testing**: Load testing and performance benchmarks for critical operations
- **Error Scenario Testing**: Comprehensive coverage of all error conditions and edge cases
- **Mock Implementations**: Complete mock framework for testing without real API calls
- **Coverage Reporting**: Automated test coverage analysis with configurable thresholds
- **Security Testing**: Input validation and injection prevention tests
- **Boundary Testing**: Edge cases for amounts, card numbers, names, emails, and phone numbers

### Enhanced
- **Test Coverage**: Increased from basic validation to 80%+ comprehensive coverage
- **Error Handling**: Improved error scenarios testing for all payment methods
- **Documentation**: Enhanced inline documentation and test examples
- **Developer Experience**: Better testing tools and automated quality checks

### Fixed
- Fixed API error responses being incorrectly parsed as PaymentResponse objects
- Now properly throws PaystackError exceptions for failed API calls
- Improved consistency between web and method channel implementations

### Testing Features Added
- Unit tests for all payment methods (card, bank transfer, mobile money)
- Integration tests for platform channel communication
- Widget tests for example app payment flows
- Error scenario testing for network failures, timeouts, and API errors
- Edge case testing for boundary values and special characters
- Performance benchmarks for validation and serialization operations
- Security tests for input sanitization and injection prevention
- Cross-platform build verification (Android, iOS, Web, Windows, Linux, macOS)

## [1.0.1] - 2025-09-27

### Fixed
- Minor fixes and improvements

## 0.0.1

* TODO: Describe initial release.
