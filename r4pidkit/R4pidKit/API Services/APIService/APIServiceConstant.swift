//
//  APIServiceConstant.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 29/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct APIServiceConstant {
  /// show logs on requests flag
  public static var showLogs: Bool = false
  
  /// user for setting request host port etc. if needed
  public static var isProduction: Bool = false
  
  /// access token on requests must be set on login or launch
  public static var accessToken: String?
  
  /// put here keys you want to mask on response or api request body on logs
  public static var maskedKeys: [Key] = [.password, .accessToken]
}

public protocol APIRequestProtocol {
  var scheme: String { get }
  var host: String { get set }
  var port: Int? { get set }
  var base: String? { get set }
  var accessToken: String? { get }
  var overrideHeaders: [String: String]? { get }
  
  func authHeaders() -> [String: String]
}

public protocol APIRequestJSONDataProtocol {
  var filename: String { get }
  var expectedResultCode: Int { get }
}

extension APIServiceConstant {
  public enum Key: String {
    //A
    case accessToken = "access_token"
    case accountName = "account_name"
    case accountNumber = "account_number"
    case action
    case actionType = "action_type"
    case addedBy = "added_by"
    case addonIDs = "addon_ids"
    case addons
    case address
    case address1
    case address2
    case afterCare = "after_care"
    case afterImages = "after_images"
    case afterImagesArr = "after_images[]"
    case afterNumberOfDays = "after_number_of_days"
    case alert
    case alpha2
    case amount
    case anniversaryDate = "anniversary_date"
    case answers
    case answerSet = "answer_set"
    case application
    case appointment
    case appointmentID = "appointment_id"
    case appointments
    case approvedAt = "approved_at"
    case appIdentifier = "app_identifier"
    case appVersion = "app_version"
    case appBuild = "app_build"
    case appDisplayName = "app_display_name"
    case aps
    case area
    case areas
    case articleID = "article_id"
    case assignedBy = "assigned_by"
    case assignee
    case atHash = "at_hash"
    case attributes
    case aud
    case avatar
    case avgRating = "avg_rating"
    case award
    case azp
    
    //B
    case bankDetails = "bank_details"
    case bankName = "bank_name"
    case bannerHTMLFormat = "banner_html_format"
    case beautyTips = "beauty_tips"
    case beforeImages = "before_images"
    case beforeImagesArr = "before_images[]"
    case benefit
    case benefits
    case birthDate = "birth_date"
    case body
    case book
    case booked
    case bookedAt = "booked_at"
    case bookedSlots = "booked_slots"
    case brand
    
    //C
    case cardID = "card_id"
    case cart
    case categories
    case category
    case categoryID = "category_id"
    case categoryName = "category_name"
    case canBook = "can_book"
    case cancelledBy = "cancelled_by"
    case center
    case centerCode = "center_code"
    case centerID = "center_id"
    case centerName = "center_name"
    case chargeID = "charge_id"
    case city
    case closeAt = "close_at"
    case code
    case commonID = "common_id"
    case commonIDType = "common_id_type"
    case company
    case concern
    case confirmationID = "confirmation_id"
    case confirmedBy = "confirmed_by"
    case congestionLevel = "congestion_level"
    case contact
    case contacts
    case content
    case cost
    case country
    case countryCode = "country_code"
    case coupon
    case coupons
    case couponCode = "coupon_code"
    case createdAt = "created_at"
    case createdBy = "created_by"
    case currency
    case currentPage = "current_page"
    case currentServiceID = "current_service_id"
    case customer
    case customers
    case cvcCheck = "cvc_check"
    case cycles
    
    //D
    case data
    case date
    case datePaid = "date_paid"
    case datePublish = "date_publish"
    case dateSent = "date_sent"
    case daysOpen = "days_open"
    case demonym
    case desc
    case description
    case details
    case deviceIdentifier = "device_identifier"
    case deviceName = "device_name"
    case deviceModel = "device_model"
    case deviceModelName = "device_model_name"
    case deviceSystemName = "device_system_name"
    case deviceSystemVersion = "device_system_version"
    case dialogHTMLFormat = "dialog_html_format"
    case discount
    case discountDollar = "discount_dollar"
    case displayName = "display_name"
    case displayNumber = "display_number"
    case duration
    
    //E
    case editedBy = "edited_by"
    case editorID = "editor_id"
    case email
    case employee
    case employeeID = "employee_id"
    case endDate = "end_date"
    case endTime = "end_time"
    case estimateDuration = "estimate_duration"
    case exp
    case expiresAt = "expires_at"
    case expMonth = "exp_month"
    case expYear = "exp_year"
    
    //F
    case facebookID = "facebook_id"
    case facebookLinked = "facebook_linked"
    case facebookToken = "facebook_token"
    case familyName = "family_name"
    case fcmToken = "fcm_token"
    case featured
    case feedback
    case feedbackType = "feedback_type"
    case filterBy = "filter_by"
    case firstName = "first_name"
    case frequency
    case freshdeskCreatedAt = "freshdesk_created_at"
    case freshdeskUpdatedAt = "freshdesk_updated_at"
    case from
    case fromAction = "from_action"
    case fromEmployee = "from_employee"
    case fullIngredients = "full_ingredients"
    case funding
    
    //G
    case gender
    case givenName = "given_name"
    case googleID = "google_id"
    case googleLinked = "google_linked"
    case googleToken = "google_token"
    case groupID = "group_id"
    
    //H
    case hasAddons = "has_addons"
    case hasCredential = "has_credential"
    case hasPhoneVerified = "has_phone_verified"
    case hd
    case heading
    case homePhone = "home_phone"
    case htmlDescription = "html_description"
    case htmlFormat = "html_format"
    case humidity
    case hydrationLevel = "hydration_level"
    
    //I
    case iat
    case id
    case identificationNumber = "identification_number"
    case identifier
    case image
    case imageCustomerapp = "image_customerapp"
    case imageInteractive = "image_interactive"
    case images
    case imagesArr = "images[]"
    case img
    case inStock = "in_stock"
    case instructions
    case intensityLevel = "intensity_level"
    case interval
    case invoiceID = "invoice_id"
    case involvedUsers = "involved_users"
    case isDefault = "is_default"
    case isDone = "is_done"
    case isLocked = "is_locked"
    case isPrivate = "is_private"
    case isRead = "is_read"
    case iss
    case isSynced = "is_synced"
    case isTask = "is_task"
    case isValid = "is_valid"
    case isVisible = "is_visible"
    
    //J
    case jobTitle = "job_title"
    //K
    
    //L
    case label
    case last4
    case lastName = "last_name"
    case lastSessionTimestamp = "last_session_timestamp"
    case lat
    case latitude
    case locale
    case locationID = "location_id"
    case lon
    case longDescription = "long_description"
    case longitude
    
    //M
    case maritalStatus = "marital_status"
    case maximumSelections = "maximum_selections"
    case membership
    case message
    case metaData = "meta_data"
    case methodID = "method_id"
    case methodTitle = "method_title"
    case methodDescription = "method_description"
    case middleName = "middle_name"
    case mobileDisplayStyle = "mobile_display_style"
    case mobilePhone = "mobile_phone"
    case moduleID = "module_id"
    case moduleType = "module_type"
    case month
    case moreInfoList = "more_info_list"
    
    //N
    case name
    case notificationID = "notification_id"
    case nationality
    case nickName = "nick_name"
    case note
    case noteID = "note_id"
    case notes
    case noteType = "note_type"
    case notSuitableFor = "not_suitable_for"
    case number
    case numberOfPumps = "number_of_pumps"
    
    //O
    case onSale = "on_sale"
    case openAt = "open_at"
    case operatingHours = "operating_hours"
    case optInPhoneCalls = "optin_phone_calls"
    case optMarketingEmail = "opt_marketing_email"
    case optMarketingSMS = "opt_marketing_sms"
    case optEmail = "opt_email"
    case optNewsLetter = "opt_news_letter"
    case optPushNotif = "opt_push_notif"
    case optLoyaltyPointsSMSEmail = "opt_loyalty_point_stmt_sms_email"
    case optSMS = "opt_sms"
    case optTransactionalEmail = "opt_transactional_email"
    case optTransactionalSMS = "opt_transactional_sms"
    case option
    case options
    case organizationName = "organization_name"
    case osVersion = "os_version"
    case otp
    case overridePrice = "override_price"
    case owner
    
    //P
    case packageID = "package_id"
    case page
    case pageSize = "page_size"
    case password
    case paymentMethod = "payment_method"
    case paymentMethodDetails = "payment_method_details"
    case periods
    case permalink = "permalink"
    case perPage = "per_page"
    case personalAddress = "personal_address"
    case phone
    case phoneCode = "phone_code"
    case phoneNumber = "phone_number"
    case picture
    case platform
    case platformDetails = "platform_details"
    case position
    case postal
    case postalCode = "postal_code"
    case preferredCenterID = "preferred_center_id"
    case preferredBranch = "preferred_branch"
    case preferredOutlet = "preferred_outlet"
    case preferredTherapistID = "preferred_therapist_id"
    case preferredTherapistName = "preferred_therapist_name"
    case preferredAssistantTherapistID = "preferred_assistant_therapist_id"
    case preferredAssistantTherapistName = "preferred_assistant_therapist_name"
    case price
    case primary
    case priority
    case procedure
    case procedures
    case product
    case productID = "product_id"
    case products
    case productVariation = "product_variation"
    case profession
    case purchasable
    case purchaseAt = "purchase_at"
    case purchasedDate = "purchased_date"
    case purchasedItems = "purchased_items"
    case purchaseID = "purchase_id"
    
    //Q
    case q
    case quiz
    case quote
    case quantity
    case query
    case question
    case questionID = "question_id"
    case questionSet = "question_set"
    case questionsSet = "questions_set"
    
    //R
    case rate
    case rating
    case raves
    case realAmount = "real_amount"
    case reasonType = "reason_type"
    case receiptNo = "receipt_no"
    case redirectURL = "redirect_url"
    case referenceID = "reference_id"
    case referralSourceID = "referral_source_id"
    case referredGuestID = "referred_guest_id"
    case referredGuestName = "referred_guest_name"
    case regComplete = "reg_complete"
    case regularPrice = "regular_price"
    case relationship
    case relationshipOf = "relationship_of"
    case required
    case reservationID = "reservation_id"
    case result
    case review
    case reviewer
    case roomID = "room_id"
    case rooms
    
    //S
    case salePrice = "sale_price"
    case skinAge = "skin_age"
    case skinAnalysis = "skin_analysis"
    case skinAnalysisID = "skin_analysis_id"
    case skinType = "skin_type"
    case src
    case search
    case selections
    case seqNum = "seq_num"
    case sequence
    case sequenceNumber = "sequence_number"
    case service
    case serviceID = "service_id"
    case services
    case sessionLeft = "session_left"
    case sessionsTotal = "session_total"
    case settings
    case shipping
    case shippingAddress = "shipping_address"
    case shippingCost = "shipping_cost"
    case shippingDiscountType = "shipping_discount_type"
    case shippingDiscountValue = "shipping_discount_value"
    case shippingFee = "shipping_fee"
    case shippingID = "shipping_id"
    case shippingMethod = "shipping_method"
    case shortContent = "short_content"
    case shortDescription = "short_description"
    case shortHeader = "short_header"
    case shortName = "short_name"
    case singleThread = "single_thread"
    case size
    case sku
    case skinConcerns = "skin_concerns"
    case slots
    case socialType = "social_type"
    case sound
    case source
    case startDate = "start_date"
    case startTime = "start_time"
    case state
    case status
    case stockStatus = "stock_status"
    case sub
    case subject
    case subPaymentMethod = "sub_payment_method"
    case subtotal
    case suitable
    case suitableFor = "suitable_for"
    case suitables
    
    //T
    case taggedUsers = "tagged_users"
    case tags
    case teas
    case temperature
    case therapist
    case therapistID = "therapist_id"
    case therapistIDs = "therapist_ids"
    case therapists
    case thread
    case ticketLink = "ticket_link"
    case ticketNumber = "ticket_number"
    case tips
    case title
    case time
    case timeSlot = "time_slot"
    case to
    case toEmployee = "to_employee"
    case token
    case total
    case totalAmount = "total_amount"
    case totalPrice = "total_price"
    case totalProductPrice = "total_product_price"
    case totalReviews = "total_reviews"
    case treatmentID = "treatment_id"
    case treatment
    case treatmentPhase = "treatment_phase"
    case treatmentPlanID = "treatment_plan_id"
    case treatmentPlanTemplateID = "treatment_plan_template_id"
    case treatments
    case type
    
    //U
    case updatedAt = "updated_at"
    case updatedBy = "updated_by"
    case unreadCount = "unread_count"
    case unreadNotificationCount = "unread_notification_count"
    case url
    case usage
    case userID = "user_id"
    case username = "username"
    case userType = "user_type"
    
    //V
    case value
    case variation
    case variations
    case variationID = "variation_id"
    case viewBy = "view_by"
    case visible
    case verified
    
    //W
    case wcDateCreated = "wc_date_created"
    case wcID = "wc_id"
    case wcOrderID = "wc_order_id"
    case wcOrderNumber = "wc_order_number"
    case whatsapp
    case window
    case windSpeed = "windSpeed"
    case workAddress = "work_address"
    case workDetails = "work_details"
    case workPhone = "work_phone"
    
    //X
    //Y
    case year
    
    //Z
    case zenotiDateCreated = "zenoti_date_created"
    case zenotiProfile = "zenoti_profile"
    case zID = "zID"
  }
}

public protocol APIResponseKeyProtocol {
  func evaluate(_ key: APIServiceConstant.Key) -> Self
}

extension APIResponseKeyProtocol {
  //A
  public var accessToken: Self {
    return evaluate(.accessToken)
  }
  public var accountName: Self {
    return evaluate(.accountName)
  }
  public var accountNumber: Self {
    return evaluate(.accountNumber)
  }
  public var action: Self {
    return evaluate(.action)
  }
  public var actionType: Self {
    return evaluate(.actionType)
  }
  public var addedBy: Self {
    return evaluate(.addedBy)
  }
  public var addonIDs: Self {
    return evaluate(.addonIDs)
  }
  public var addons: Self {
    return evaluate(.addons)
  }
  public var address: Self {
    return evaluate(.address)
  }
  public var address1: Self {
    return evaluate(.address1)
  }
  public var address2: Self {
    return evaluate(.address2)
  }
  public var afterCare: Self {
    return evaluate(.afterCare)
  }
  public var afterImages: Self {
    return evaluate(.afterImages)
  }
  public var afterImagesArr: Self {
    return evaluate(.afterImagesArr)
  }
  public var afterNumberOfDays: Self {
    return evaluate(.afterNumberOfDays)
  }
  public var alert: Self {
    return evaluate(.alert)
  }
  public var alpha2: Self {
    return evaluate(.alpha2)
  }
  public var amount: Self {
    return evaluate(.amount)
  }
  public var anniversaryDate: Self {
    return evaluate(.anniversaryDate)
  }
  public var answers: Self {
    return evaluate(.answers)
  }
  public var answerSet: Self {
    return evaluate(.answerSet)
  }
  public var application: Self {
    return evaluate(.application)
  }
  public var appointment: Self {
    return evaluate(.appointment)
  }
  public var appointmentID: Self {
    return evaluate(.appointmentID)
  }
  public var appointments: Self {
    return evaluate(.appointments)
  }
  public var approvedAt: Self {
    return evaluate(.approvedAt)
  }
  public var appIdentifier: Self {
    return evaluate(.appIdentifier)
  }
  public var appVersion: Self {
    return evaluate(.appVersion)
  }
  public var appBuild: Self {
    return evaluate(.appBuild)
  }
  public var appDisplayName: Self {
    return evaluate(.appDisplayName)
  }
  public var aps: Self {
    return evaluate(.aps)
  }
  public var area: Self {
    return evaluate(.area)
  }
  public var areas: Self {
    return evaluate(.areas)
  }
  public var articleID: Self {
    return evaluate(.articleID)
  }
  public var assignedBy: Self {
    return evaluate(.assignedBy)
  }
  public var assignee: Self {
    return evaluate(.assignee)
  }
  public var atHash: Self {
    return evaluate(.atHash)
  }
  public var attributes: Self {
    return evaluate(.attributes)
  }
  public var aud: Self {
    return evaluate(.aud)
  }
  public var avatar: Self {
    return evaluate(.avatar)
  }
  public var avgRating: Self {
    return evaluate(.avgRating)
  }
  public var award: Self {
    return evaluate(.award)
  }
  public var azp: Self {
    return evaluate(.azp)
  }
  
  //B
  public var bankDetails: Self {
    return evaluate(.bankDetails)
  }
  public var bankName: Self {
    return evaluate(.bankName)
  }
  public var bannerHTMLFormat: Self {
    return evaluate(.bannerHTMLFormat)
  }
  public var beautyTips: Self {
    return evaluate(.beautyTips)
  }
  public var beforeImages: Self {
    return evaluate(.beforeImages)
  }
  public var beforeImagesArr: Self {
    return evaluate(.beforeImagesArr)
  }
  public var benefit: Self {
    return evaluate(.benefit)
  }
  public var benefits: Self {
    return evaluate(.benefits)
  }
  public var birthDate: Self {
    return evaluate(.birthDate)
  }
  public var body: Self {
    return evaluate(.body)
  }
  public var book: Self {
    return evaluate(.book)
  }
  public var booked: Self {
    return evaluate(.booked)
  }
  public var bookedAt: Self {
    return evaluate(.bookedAt)
  }
  public var bookedSlots: Self {
    return evaluate(.bookedSlots)
  }
  public var brand: Self {
    return evaluate(.brand)
  }
  
  //C
  public var cardID: Self {
    return evaluate(.cardID)
  }
  public var cart: Self {
    return evaluate(.cart)
  }
  public var categories: Self {
    return evaluate(.categories)
  }
  public var category: Self {
    return evaluate(.category)
  }
  public var categoryID: Self {
    return evaluate(.categoryID)
  }
  public var categoryName: Self {
    return evaluate(.categoryName)
  }
  public var canBook: Self {
    return evaluate(.canBook)
  }
  public var cancelledBy: Self {
    return evaluate(.cancelledBy)
  }
  public var center: Self {
    return evaluate(.center)
  }
  public var centerCode: Self {
    return evaluate(.centerCode)
  }
  public var centerName: Self {
    return evaluate(.centerName)
  }
  public var centerID: Self {
    return evaluate(.centerID)
  }
  public var chargeID: Self {
    return evaluate(.chargeID)
  }
  public var city: Self {
    return evaluate(.city)
  }
  public var closeAt: Self {
    return evaluate(.closeAt)
  }
  public var code: Self {
    return evaluate(.code)
  }
  public var commonID: Self {
    return evaluate(.commonID)
  }
  public var commonIDType: Self {
    return evaluate(.commonIDType)
  }
  public var company: Self {
    return evaluate(.company)
  }
  public var concern: Self {
    return evaluate(.concern)
  }
  public var confirmationID: Self {
    return evaluate(.confirmationID)
  }
  public var confirmedBy: Self {
    return evaluate(.confirmedBy)
  }
  public var congestionLevel: Self {
    return evaluate(.congestionLevel)
  }
  public var contact: Self {
    return evaluate(.contact)
  }
  public var contacts: Self {
    return evaluate(.contacts)
  }
  public var content: Self {
    return evaluate(.content)
  }
  public var cost: Self {
    return evaluate(.cost)
  }
  public var country: Self {
    return evaluate(.country)
  }
  public var countryCode: Self {
    return evaluate(.countryCode)
  }
  public var coupon: Self {
    return evaluate(.coupon)
  }
  public var coupons: Self {
    return evaluate(.coupons)
  }
  public var couponCode: Self {
    return evaluate(.couponCode)
  }
  public var createdAt: Self {
    return evaluate(.createdAt)
  }
  public var createdBy: Self {
    return evaluate(.createdBy)
  }
  public var  currentServiceID: Self {
    return evaluate(.currentServiceID)
  }
  public var currency: Self {
    return evaluate(.currency)
  }
  public var currentPage: Self {
    return evaluate(.currentPage)
  }
  public var customer: Self {
    return evaluate(.customer)
  }
  public var customers: Self {
    return evaluate(.customers)
  }
  public var cvcCheck: Self {
    return evaluate(.cvcCheck)
  }
  public var cycles: Self {
    return evaluate(.cycles)
  }
  
  //D
  public var data: Self {
    return evaluate(.data)
  }
  public var date: Self {
    return evaluate(.date)
  }
  public var datePaid: Self {
    return evaluate(.datePaid)
  }
  public var datePublish: Self {
    return evaluate(.datePublish)
  }
  public var dateSent: Self {
    return evaluate(.dateSent)
  }
  public var daysOpen: Self {
    return evaluate(.daysOpen)
  }
  public var demonym: Self {
    return evaluate(.demonym)
  }
  public var desc: Self {
    return evaluate(.desc)
  }
  public var description: Self {
    return evaluate(.description)
  }
  public var details: Self {
    return evaluate(.details)
  }
  public var deviceIdentifier: Self {
    return evaluate(.deviceIdentifier)
  }
  public var deviceModel: Self {
    return evaluate(.deviceModel)
  }
  public var deviceModelName: Self {
    return evaluate(.deviceModelName)
  }
  public var deviceSystemName: Self {
    return evaluate(.deviceSystemName)
  }
  public var deviceSystemVersion: Self {
    return evaluate(.deviceSystemVersion)
  }
  public var dialogHTMLFormat: Self {
    return evaluate(.dialogHTMLFormat)
  }
  public var discount: Self {
    return evaluate(.discount)
  }
  public var discountDollar: Self {
    return evaluate(.discountDollar)
  }
  public var displayName: Self {
    return evaluate(.displayName)
  }
  public var displayNumber: Self {
    return evaluate(.displayNumber)
  }
  public var duration: Self  {
    return evaluate(.duration)
  }
  
  //E
  public var editedBy: Self {
    return evaluate(.editedBy)
  }
  public var editorID: Self {
    return evaluate(.editorID)
  }
  public var email: Self {
    return evaluate(.email)
  }
  public var employee: Self {
    return evaluate(.employee)
  }
  public var employeeID: Self {
    return evaluate(.employeeID)
  }
  public var endDate: Self {
    return evaluate(.endDate)
  }
  public var endTime: Self {
    return evaluate(.endTime)
  }
  public var estimateDuration: Self {
    return evaluate(.estimateDuration)
  }
  public  var exp: Self {
    return evaluate(.exp)
  }
  public var expiresAt: Self {
    return evaluate(.expiresAt)
  }
  public var expMonth: Self {
    return evaluate(.expMonth)
  }
  public var expYear: Self {
    return evaluate(.expYear)
  }
  
  //F
  public var facebookID: Self {
    return evaluate(.facebookID)
  }
  public var facebookLinked: Self {
    return evaluate(.facebookLinked)
  }
  public var facebookToken: Self {
    return evaluate(.facebookToken)
  }
  public var familyName: Self {
    return evaluate(.familyName)
  }
  public var fcmToken: Self {
    return evaluate(.fcmToken)
  }
  public var featured: Self {
    return evaluate(.featured)
  }
  public var feedback: Self {
    return evaluate(.feedback)
  }
  public var feedbackType: Self {
    return evaluate(.feedbackType)
  }
  public var filterBy: Self {
    return evaluate(.filterBy)
  }
  public var firstName: Self {
    return evaluate(.firstName)
  }
  public var frequency: Self {
    return evaluate(.frequency)
  }
  public var freshdeskCreatedAt: Self {
    return evaluate(.freshdeskCreatedAt)
  }
  public var freshdeskUpdatedAt: Self {
    return evaluate(.freshdeskUpdatedAt)
  }
  public var from: Self {
    return evaluate(.from)
  }
  public var fromAction: Self {
    return evaluate(.fromAction)
  }
  public var fromEmployee: Self {
    return evaluate(.fromEmployee)
  }
  public var fullIngredients: Self {
    return evaluate(.fullIngredients)
  }
  public var funding: Self {
    return evaluate(.funding)
  }
  
  //G
  public var gender: Self {
    return evaluate(.gender)
  }
  public var givenName: Self {
    return evaluate(.givenName)
  }
  public var googleID: Self {
    return evaluate(.googleID)
  }
  public var googleLinked: Self {
    return evaluate(.googleLinked)
  }
  public var googleToken: Self {
    return evaluate(.googleToken)
  }
  public var groupID: Self {
    return evaluate(.groupID)
  }
  
  //H
  public var hasAddons: Self {
    return evaluate(.hasAddons)
  }
  public var hasCredential: Self {
    return evaluate(.hasCredential)
  }
  public var hasPhoneVerified: Self {
    return evaluate(.hasPhoneVerified)
  }
  public var hd: Self {
    return evaluate(.hd)
  }
  public var heading: Self {
    return evaluate(.heading)
  }
  public var homePhone: Self {
    return evaluate(.homePhone)
  }
  public var htmlDescription: Self {
    return evaluate(.htmlDescription)
  }
  public var htmlFormat: Self {
    return evaluate(.htmlFormat)
  }
  public var humidity: Self {
    return evaluate(.humidity)
  }
  public var hydrationLevel: Self {
    return evaluate(.hydrationLevel)
  }
  
  //I
  public var iat: Self {
    return evaluate(.iat)
  }
  public var id: Self {
    return evaluate(.id)
  }
  public var identificationNumber: Self {
    return evaluate(.identificationNumber)
  }
  public var identifier: Self {
    return evaluate(.identifier)
  }
  public var image: Self {
    return evaluate(.image)
  }
  public var imageCustomerapp: Self {
    return evaluate(.imageCustomerapp)
  }
  public var imageInteractive: Self {
    return evaluate(.imageInteractive)
  }
  public var images: Self {
    return evaluate(.images)
  }
  public var imagesArr: Self {
    return evaluate(.imagesArr)
  }
  public var img: Self {
    return evaluate(.img)
  }
  public var inStock: Self {
    return evaluate(.inStock)
  }
  public var instructions: Self {
    return evaluate(.instructions)
  }
  public var intensityLevel: Self {
    return evaluate(.intensityLevel)
  }
  public var interval: Self {
    return evaluate(.interval)
  }
  public var invoiceID: Self {
    return evaluate(.invoiceID)
  }
  public var involvedUsers: Self {
    return evaluate(.involvedUsers)
  }
  public var isDefault: Self {
    return evaluate(.isDefault)
  }
  public var isDone: Self {
    return evaluate(.isDone)
  }
  public var isLocked: Self {
    return evaluate(.isLocked)
  }
  public var isPrivate: Self {
    return evaluate(.isPrivate)
  }
  public var isRead: Self {
    return evaluate(.isRead)
  }
  public  var iss: Self {
    return evaluate(.iss)
  }
  public var isSynced: Self {
    return evaluate(.isSynced)
  }
  public var isTask: Self {
    return evaluate(.isTask)
  }
  public var isValid: Self {
    return evaluate(.isValid)
  }
  public var isVisible: Self {
    return evaluate(.isVisible)
  }
  
  //J
  public var jobTitle: Self {
    return evaluate(.jobTitle)
  }
  
  //K
  
  //L
  public var label: Self {
    return evaluate(.label)
  }
  public var last4: Self {
    return evaluate(.last4)
  }
  public var lastName: Self {
    return evaluate(.lastName)
  }
  public var lastSessionTimestamp: Self {
    return evaluate(.lastSessionTimestamp)
  }
  public var lat: Self {
    return evaluate(.lat)
  }
  public var latitude: Self {
    return evaluate(.latitude)
  }
  public var locale: Self {
    return evaluate(.locale)
  }
  public var locationID: Self {
    return evaluate(.locationID)
  }
  public var lon: Self {
    return evaluate(.lon)
  }
  public var longDescription: Self {
    return evaluate(.longDescription)
  }
  public var longitude: Self {
    return evaluate(.longitude)
  }
  
  //M
  public var maritalStatus: Self {
    return evaluate(.maritalStatus)
  }
  public var maximumSelections: Self {
    return evaluate(.maximumSelections)
  }
  public var membership: Self {
    return evaluate(.membership)
  }
  public var message: Self {
    return evaluate(.message)
  }
  public var metaData: Self {
    return evaluate(.metaData)
  }
  public var methodID: Self {
    return evaluate(.methodID)
  }
  public var methodTitle: Self {
    return evaluate(.methodTitle)
  }
  public var methodDescription: Self {
    return evaluate(.methodDescription)
  }
  public var middleName: Self {
    return evaluate(.middleName)
  }
  public var mobileDisplayStyle: Self {
    return evaluate(.mobileDisplayStyle)
  }
  public var mobilePhone: Self {
    return evaluate(.mobilePhone)
  }
  public var moduleID: Self {
    return evaluate(.moduleID)
  }
  public var moduleType: Self {
    return evaluate(.moduleType)
  }
  public var month: Self {
    return evaluate(.month)
  }
  public var moreInfoList: Self {
    return evaluate(.moreInfoList)
  }
  
  //N
  public var name: Self {
    return evaluate(.name)
  }
  public var notificationID: Self {
    return evaluate(.notificationID)
  }
  public var nationality: Self {
    return evaluate(.nationality)
  }
  public var nickName: Self {
    return evaluate(.nickName)
  }
  public var note: Self {
    return evaluate(.note)
  }
  public var noteID: Self {
    return evaluate(.noteID)
  }
  public var notes: Self {
    return evaluate(.notes)
  }
  public var noteType: Self {
    return evaluate(.noteType)
  }
  public var notSuitableFor: Self {
    return evaluate(.notSuitableFor)
  }
  public var number: Self {
    return evaluate(.number)
  }
  public var numberOfPumps: Self {
    return evaluate(.numberOfPumps)
  }
  
  //O
  public var onSale: Self {
    return evaluate(.onSale)
  }
  public var openAt: Self {
    return evaluate(.openAt)
  }
  public var operatingHours: Self {
    return evaluate(.operatingHours)
  }
  public var optInPhoneCalls: Self {
    return evaluate(.optInPhoneCalls)
  }
  public var optEmail: Self {
    return evaluate(.optEmail)
  }
  public var optMarketingEmail: Self {
    return evaluate(.optMarketingEmail)
  }
  public var optMarketingSMS: Self {
    return evaluate(.optMarketingSMS)
  }
  public var optNewsLetter: Self {
    return evaluate(.optNewsLetter)
  }
  public var optPushNotif: Self {
    return evaluate(.optPushNotif)
  }
  public var optLoyaltyPointsSMSEmail: Self {
    return evaluate(.optLoyaltyPointsSMSEmail)
  }
  public var optSMS: Self {
    return evaluate(.optSMS)
  }
  public var optTransactionalEmail: Self {
    return evaluate(.optTransactionalEmail)
  }
  public var optTransactionalSMS: Self {
    return evaluate(.optTransactionalSMS)
  }
  public var option: Self {
    return evaluate(.option)
  }
  public var options: Self {
    return evaluate(.options)
  }
  public var organizationName: Self {
    return evaluate(.organizationName)
  }
  public var osVersion: Self {
    return evaluate(.osVersion)
  }
  public var otp: Self {
    return evaluate(.otp)
  }
  public var overridePrice: Self {
    return evaluate(.overridePrice)
  }
  public var owner: Self {
    return evaluate(.owner)
  }
  
  //P
  public var packageID: Self {
    return evaluate(.packageID)
  }
  public var page: Self {
    return evaluate(.page)
  }
  public var pageSize: Self {
    return evaluate(.pageSize)
  }
  public var password: Self {
    return evaluate(.password)
  }
  public var paymentMethod: Self {
    return evaluate(.paymentMethod)
  }
  public var paymentMethodDetails: Self {
    return evaluate(.paymentMethodDetails)
  }
  public var periods: Self {
    return evaluate(.periods)
  }
  public var permalink: Self {
    return evaluate(.permalink)
  }
  public var perPage: Self {
    return evaluate(.perPage)
  }
  public var personalAddress: Self {
    return evaluate(.personalAddress)
  }
  public var phone: Self {
    return evaluate(.phone)
  }
  public var phoneCode: Self {
    return evaluate(.phoneCode)
  }
  public var phoneNumber: Self {
    return evaluate(.phoneNumber)
  }
  public var picture: Self {
    return evaluate(.picture)
  }
  public var platform: Self {
    return evaluate(.platform)
  }
  public var platformDetails: Self {
    return evaluate(.platformDetails)
  }
  public var position: Self {
    return evaluate(.position)
  }
  public var postal: Self {
    return evaluate(.postal)
  }
  public var postalCode: Self {
    return evaluate(.postalCode)
  }
  public var preferredCenterID: Self {
    return evaluate(.preferredCenterID)
  }
  public var preferredBranch: Self {
    return evaluate(.preferredBranch)
  }
  public var preferredOutlet: Self {
    return evaluate(.preferredOutlet)
  }
  public var preferredTherapistID: Self {
    return evaluate(.preferredTherapistID)
  }
  public var preferredTherapistName: Self {
    return evaluate(.preferredTherapistName)
  }
  public var preferredAssistantTherapistID: Self {
    return evaluate(.preferredAssistantTherapistID)
  }
  public var preferredAssistantTherapistName: Self {
    return evaluate(.preferredAssistantTherapistName)
  }
  public var price: Self {
    return evaluate(.price)
  }
  public var primary: Self {
    return evaluate(.primary)
  }
  public var priority: Self {
    return evaluate(.priority)
  }
  public var procedure: Self {
    return evaluate(.procedure)
  }
  public var procedures: Self {
    return evaluate(.procedures)
  }
  public var product: Self {
    return evaluate(.product)
  }
  public var productID: Self {
    return evaluate(.productID)
  }
  public var products: Self {
    return evaluate(.products)
  }
  public var productVariation: Self {
    return evaluate(.productVariation)
  }
  public var profession: Self {
    return evaluate(.profession)
  }
  public var purchasable: Self {
    return evaluate(.purchasable)
  }
  public var purchaseAt: Self {
    return evaluate(.purchaseAt)
  }
  public var purchasedDate: Self {
    return evaluate(.purchasedDate)
  }
  public var purchasedItems: Self {
    return evaluate(.purchasedItems)
  }
  public var purchaseID: Self {
    return evaluate(.purchaseID)
  }
  
  //Q
  public var q: Self  {
    return evaluate(.q)
  }
  public var quiz: Self {
    return evaluate(.quiz)
  }
  public var quote: Self {
    return evaluate(.quote)
  }
  public var quantity: Self {
    return evaluate(.quantity)
  }
  public var query: Self {
    return evaluate(.query)
  }
  public var question: Self {
    return evaluate(.question)
  }
  public var questionID: Self {
    return evaluate(.questionID)
  }
  public var questionSet: Self {
    return evaluate(.questionSet)
  }
  public var questionsSet: Self {
    return evaluate(.questionsSet)
  }
  
  //R
  public var rate: Self {
    return evaluate(.rate)
  }
  public var rating: Self {
    return evaluate(.rating)
  }
  public var raves: Self {
    return evaluate(.raves)
  }
  public var realAmount: Self {
    return evaluate(.realAmount)
  }
  public var reasonType: Self {
    return evaluate(.reasonType)
  }
  public var receiptNo: Self {
    return evaluate(.receiptNo)
  }
  public var redirectURL: Self {
    return evaluate(.redirectURL)
  }
  public var referenceID: Self {
    return evaluate(.referenceID)
  }
  public var referralSourceID: Self {
    return evaluate(.referralSourceID)
  }
  public var referredGuestID: Self {
    return evaluate(.referredGuestID)
  }
  public var referredGuestName: Self {
    return evaluate(.referredGuestName)
  }
  public var regComplete: Self {
    return evaluate(.regComplete)
  }
  public  var regularPrice: Self {
    return evaluate(.regularPrice)
  }
  public var relationship: Self {
    return evaluate(.relationship)
  }
  public var relationshipOf: Self {
    return evaluate(.relationshipOf)
  }
  public var required: Self {
    return evaluate(.required)
  }
  public var reservationID: Self {
    return evaluate(.reservationID)
  }
  public var result: Self {
    return evaluate(.result)
  }
  public var review: Self {
    return evaluate(.review)
  }
  public var reviewer: Self {
    return evaluate(.reviewer)
  }
  public var roomID: Self {
    return evaluate(.roomID)
  }
  public var rooms: Self {
    return evaluate(.rooms)
  }
  
  //S
  public var salePrice: Self {
    return evaluate(.salePrice)
  }
  public var skinAge: Self {
    return evaluate(.skinAge)
  }
  public var skinAnalysis: Self {
    return evaluate(.skinAnalysis)
  }
  public var skinAnalysisID: Self {
    return evaluate(.skinAnalysisID)
  }
  public var skinType: Self {
    return evaluate(.skinType)
  }
  public var src: Self {
    return evaluate(.src)
  }
  public var search: Self {
    return evaluate(.search)
  }
  public var selections: Self {
    return evaluate(.selections)
  }
  public var seqNum: Self {
    return evaluate(.seqNum)
  }
  public var sequence: Self {
    return evaluate(.sequence)
  }
  public var sequenceNumber: Self {
    return evaluate(.sequenceNumber)
  }
  public var service: Self {
    return evaluate(.service)
  }
  public var serviceID: Self {
    return evaluate(.serviceID)
  }
  public var services: Self {
    return evaluate(.services)
  }
  public var sessionLeft: Self {
    return evaluate(.sessionLeft)
  }
  public var sessionsTotal: Self {
    return evaluate(.sessionsTotal)
  }
  public var settings: Self {
    return evaluate(.settings)
  }
  public var shipping: Self {
    return evaluate(.shipping)
  }
  public var shippingAddress: Self {
    return evaluate(.shippingAddress)
  }
  public var shippingCost: Self {
    return evaluate(.shippingCost)
  }
  public var shippingDiscountType: Self {
    return evaluate(.shippingDiscountType)
  }
  public var shippingDiscountValue: Self {
    return evaluate(.shippingDiscountValue)
  }
  public var shippingFee: Self {
    return evaluate(.shippingFee)
  }
  public var shippingID: Self {
    return evaluate(.shippingID)
  }
  public var shippingMethod: Self {
    return evaluate(.shippingMethod)
  }
  public var shortContent: Self {
    return evaluate(.shortContent)
  }
  public var shortDescription: Self {
    return evaluate(.shortDescription)
  }
  public var shortHeader: Self {
    return evaluate(.shortHeader)
  }
  public var shortName: Self {
    return evaluate(.shortName)
  }
  public var singleThread: Self {
    return evaluate(.singleThread)
  }
  public var size: Self {
    return evaluate(.size)
  }
  public var sku: Self {
    return evaluate(.sku)
  }
  public var skinConcerns: Self {
    return evaluate(.skinConcerns)
  }
  public var slots: Self {
    return evaluate(.slots)
  }
  public var socialType: Self {
    return evaluate(.socialType)
  }
  public var source: Self {
    return evaluate(.source)
  }
  public var sound: Self {
    return evaluate(.sound)
  }
  public var startDate: Self {
    return evaluate(.startDate)
  }
  public var startTime: Self {
    return evaluate(.startTime)
  }
  public var state: Self {
    return evaluate(.state)
  }
  public var status: Self {
    return evaluate(.status)
  }
  public var stockStatus: Self {
    return evaluate(.stockStatus)
  }
  public var sub: Self {
    return evaluate(.sub)
  }
  public var subject: Self {
    return evaluate(.subject)
  }
  public var subPaymentMethod: Self {
    return evaluate(.subPaymentMethod)
  }
  public var subtotal: Self {
    return evaluate(.subtotal)
  }
  public var suitable: Self {
    return evaluate(.suitable)
  }
  public var suitableFor: Self {
    return evaluate(.suitableFor)
  }
  public var suitables: Self {
    return evaluate(.suitables)
  }
  
  //T
  public var taggedUsers: Self {
    return evaluate(.taggedUsers)
  }
  public var tags: Self {
    return evaluate(.tags)
  }
  public var teas: Self {
    return evaluate(.teas)
  }
  public var temperature: Self {
    return evaluate(.temperature)
  }
  public var therapist: Self {
    return evaluate(.therapist)
  }
  public var therapistID: Self {
    return evaluate(.therapistID)
  }
  public var therapistIDs: Self {
    return evaluate(.therapistIDs)
  }
  public var therapists: Self {
    return evaluate(.therapists)
  }
  public var thread: Self {
    return evaluate(.thread)
  }
  public var ticketLink: Self {
    return evaluate(.ticketLink)
  }
  public var ticketNumber: Self {
    return evaluate(.ticketNumber)
  }
  public var tips: Self {
    return evaluate(.tips)
  }
  public var title: Self {
    return evaluate(.title)
  }
  public var time: Self {
    return evaluate(.time)
  }
  public var timeSlot: Self {
    return evaluate(.timeSlot)
  }
  public var to: Self {
    return evaluate(.to)
  }
  public var toEmployee: Self {
    return evaluate(.toEmployee)
  }
  public var token: Self {
    return evaluate(.token)
  }
  public var total: Self {
    return evaluate(.total)
  }
  public var totalAmount: Self {
    return evaluate(.totalAmount)
  }
  public var totalPrice: Self {
    return evaluate(.totalPrice)
  }
  public var totalProductPrice: Self {
    return evaluate(.totalProductPrice)
  }
  public var totalReviews: Self {
    return evaluate(.totalReviews)
  }
  public var treatmentID: Self {
    return evaluate(.treatmentID)
  }
  public var treatment: Self {
    return evaluate(.treatment)
  }
  public var treatmentPhase: Self {
    return evaluate(.treatmentPhase)
  }
  public var treatmentPlanID: Self {
    return evaluate(.treatmentPlanID)
  }
  public var treatmentPlanTemplateID: Self {
    return evaluate(.treatmentPlanTemplateID)
  }
  public var treatments: Self {
    return evaluate(.treatments)
  }
  public var type: Self {
    return evaluate(.type)
  }
  
  //U
  public var updatedAt: Self {
    return evaluate(.updatedAt)
  }
  public var updatedBy: Self {
    return evaluate(.updatedBy)
  }
  public var unreadCount: Self {
    return evaluate(.unreadCount)
  }
  public var unreadNotificationCount: Self {
    return evaluate(.unreadNotificationCount)
  }
  public var url: Self {
    return evaluate(.url)
  }
  public var usage: Self {
    return evaluate(.usage)
  }
  public var userID: Self {
    return evaluate(.userID)
  }
  public var username: Self {
    return evaluate(.username)
  }
  public var userType: Self {
    return evaluate(.userType)
  }
  
  //V
  public var value: Self {
    return evaluate(.value)
  }
  public var variation: Self {
    return evaluate(.variation)
  }
  public var variations: Self {
    return evaluate(.variations)
  }
  public var variationID: Self {
    return evaluate(.variationID)
  }
  public var viewBy: Self {
    return evaluate(.viewBy)
  }
  public var visible: Self {
    return evaluate(.visible)
  }
  public var verified: Self {
    return evaluate(.verified)
  }
  
  //W
  public var wcDateCreated: Self {
    return evaluate(.wcDateCreated)
  }
  public var wcID: Self {
    return evaluate(.wcID)
  }
  public var wcOrderID: Self {
    return evaluate(.wcOrderID)
  }
  public var wcOrderNumber: Self {
    return evaluate(.wcOrderNumber)
  }
  public var whatsapp: Self {
    return evaluate(.whatsapp)
  }
  public var window: Self {
    return evaluate(.window)
  }
  public var windSpeed: Self {
    return evaluate(.windSpeed)
  }
  public var workAddress: Self {
    return evaluate(.workAddress)
  }
  public var workDetails: Self {
    return evaluate(.workDetails)
  }
  public var workPhone: Self {
    return evaluate(.workPhone)
  }
  
  //X
  
  //Y
  public var year: Self {
    return evaluate(.year)
  }
  
  //Z
  public var zenotiDateCreated: Self {
    return evaluate(.zenotiDateCreated)
  }
  public var zenotiProfile: Self {
    return evaluate(.zenotiProfile)
  }
  public var zID: Self {
    return evaluate(.zID)
  }
}

// MARK: - APIResponseKeyProtocol
extension JSON: APIResponseKeyProtocol {
  public subscript(_  key: APIServiceConstant.Key) -> JSON {
    return self[key.rawValue]
  }
  
  public func evaluate(_ key: APIServiceConstant.Key) -> JSON {
    return self[key.rawValue]
  }
  
  public func toDate(format: String = .ymdhmsDateFormat) -> Date? {
    return string?.toDate(format: format)
  }
  
  public func toNSDate(format: String = .ymdhmsDateFormat) -> NSDate? {
    return toDate(format: format) as NSDate?
  }
  
  /// convert value to string if possible or a number
  public var numberString: String? {
    return string ?? number?.stringValue
  }
}

extension String {  
  public func toDate(format: String = .ymdhmsDateFormat) -> Date? {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = format
    return dateFormater.date(from: self)
  }
}

extension Data {
  mutating func append(_ string: String) {
    guard let data = string.data(using: .utf8) else { return }
    append(data)
  }
}

extension URLQueryItem {
  public init(key: APIServiceConstant.Key, value: String?) {
    self.init(name: key.rawValue, value: value)
  }
}

public protocol APIServiceError401HandlerProtocol: class {
  func didReceiveError401(notification: Notification)
}

extension APIServiceError401HandlerProtocol {
  public func observeError401() {
    NotificationCenter.default.addObserver(forName: .apiServiceError401Notification, object: nil, queue: .main) { [weak self] (notification) in
      guard let `self` = self else { return }
      self.didReceiveError401(notification: notification)
    }
  }
  
  public func unobserveError401() {
    NotificationCenter.default.removeObserver(self, name: .apiServiceError401Notification, object: nil)
  }
}

extension Notification.Name {
  public static let apiServiceError401Notification = Notification.Name("apiServiceError401Notification")
}

public protocol APILogProtocol {
  func logSelf()
}

extension APILogProtocol {
  public func logSelf() {
  }
  
  public static func apiLog(_ items: Any...) {
    guard APIServiceConstant.showLogs else { return }
    for (i, item) in items.enumerated() {
      print(item, terminator: (i + 1) == items.count ? "\n" : " ")
    }
  }
}
