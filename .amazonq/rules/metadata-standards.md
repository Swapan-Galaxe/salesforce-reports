# Salesforce Metadata Best Practices

When creating or modifying Salesforce metadata, ALWAYS follow these rules:

## Naming Conventions
- **Roles**: Use underscores for API names (e.g., `MDL_Super_User`)
- **Permission Sets**: Descriptive with suffix `_Permissions` (e.g., `MDL_Manager_Permissions`)
- **Profiles**: Clear business names (e.g., `MDLive`, `Sales User`)
- **Custom Objects**: PascalCase with `__c` suffix (e.g., `Provider__c`)
- **Custom Fields**: Descriptive with `__c` suffix (e.g., `License_Number__c`)
- **Flows**: PascalCase (e.g., `Account_Validation_Flow`)
- **Validation Rules**: Descriptive (e.g., `Email_Required`)
- **Workflows**: Clear purpose (e.g., `Lead_Assignment_Workflow`)
- **Apex Classes**: PascalCase (e.g., `AccountService`, `ContactController`)
- **Apex Triggers**: ObjectName + Trigger (e.g., `AccountTrigger`)
- **LWC Components**: camelCase (e.g., `salesDashboard`)
- **Custom Labels**: Descriptive (e.g., `Error_Message_Invalid_Email`)
- **Custom Metadata**: PascalCase with `__mdt` suffix (e.g., `Configuration__mdt`)

## Role Hierarchy
```
✅ CORRECT:
- Define parent role using <parentRole> tag
- Keep hierarchy max 5 levels deep
- Use business-aligned structure

❌ WRONG:
- Circular references
- Too many levels (>5)
- Missing parent relationships
```

## Permission Sets
```xml
✅ CORRECT:
<PermissionSet>
    <label>User Friendly Name</label>
    <description>Clear purpose description</description>
    <hasActivationRequired>false</hasActivationRequired>
    <!-- Group related permissions -->
    <userPermissions>...</userPermissions>
    <objectPermissions>...</objectPermissions>
    <classAccesses>...</classAccesses>
</PermissionSet>

❌ WRONG:
- Missing descriptions
- Mixing unrelated permissions
- No clear purpose
```

## Object Permissions
```xml
✅ CORRECT - CRU Access:
<objectPermissions>
    <allowCreate>true</allowCreate>
    <allowDelete>false</allowDelete>
    <allowEdit>true</allowEdit>
    <allowRead>true</allowRead>
    <modifyAllRecords>false</modifyAllRecords>
    <object>Account</object>
    <viewAllRecords>false</viewAllRecords>
</objectPermissions>

✅ CORRECT - View All/Modify All:
<objectPermissions>
    <allowCreate>true</allowCreate>
    <allowDelete>true</allowDelete>  <!-- Required for modifyAllRecords -->
    <allowEdit>true</allowEdit>
    <allowRead>true</allowRead>
    <modifyAllRecords>true</modifyAllRecords>
    <object>Account</object>
    <viewAllRecords>true</viewAllRecords>
</objectPermissions>
```

## License Compatibility
**Salesforce Platform License:**
- ❌ No Lead access
- ❌ No Opportunity access
- ❌ No ViewAllData/ModifyAllData
- ✅ Account, Contact, Task access
- ✅ Custom objects

**Full Salesforce License:**
- ✅ All standard objects
- ✅ ViewAllData/ModifyAllData
- ✅ Lead conversion
- ✅ All permissions

## Profile Best Practices
```xml
✅ CORRECT:
<Profile>
    <custom>true</custom>  <!-- Always true for custom profiles -->
    <userLicense>Salesforce</userLicense>
    <!-- Minimal permissions in profile -->
    <!-- Use permission sets for additional access -->
</Profile>

❌ WRONG:
- <custom>false</custom> for custom profiles
- Putting all permissions in profile
- Not using permission sets
```

## Deployment Order
1. **Profiles** (if new)
2. **Roles** (parent to child)
3. **Permission Sets**
4. **Users**
5. **Permission Set Assignments**

## Security Best Practices
- ✅ Use `with sharing` in Apex classes
- ✅ Use `WITH USER_MODE` in SOQL (API 58+)
- ✅ Use `AccessLevel.USER_MODE` in DML (API 58+)
- ✅ Principle of least privilege
- ✅ Permission sets over profile permissions
- ❌ Never use `without sharing` unless required
- ❌ Don't grant unnecessary permissions

## Testing Requirements
- ✅ Test with actual users
- ✅ Verify CRUD access
- ✅ Test role hierarchy (data visibility)
- ✅ Validate permission set assignments
- ✅ Check license compatibility

## Documentation
Always include:
- Description in metadata
- Purpose of role/permission set
- Which users should have it
- Dependencies

## Version Control
```
force-app/
├── main/
│   └── default/
│       ├── profiles/
│       ├── permissionsets/
│       ├── roles/
│       ├── classes/
│       ├── triggers/
│       ├── lwc/
│       ├── aura/
│       ├── objects/
│       ├── flows/
│       ├── workflows/
│       ├── validationRules/
│       ├── layouts/
│       ├── tabs/
│       ├── applications/
│       ├── labels/
│       ├── staticresources/
│       ├── reports/
│       ├── dashboards/
│       └── customMetadata/
```

## Custom Objects
```xml
✅ CORRECT:
<CustomObject>
    <label>Provider</label>
    <pluralLabel>Providers</pluralLabel>
    <nameField>
        <label>Provider Name</label>
        <type>Text</type>
    </nameField>
    <deploymentStatus>Deployed</deploymentStatus>
    <sharingModel>ReadWrite</sharingModel>
    <enableActivities>true</enableActivities>
    <enableReports>true</enableReports>
</CustomObject>
```

## Custom Fields
```xml
✅ CORRECT:
<CustomField>
    <fullName>License_Number__c</fullName>
    <label>License Number</label>
    <type>Text</type>
    <length>50</length>
    <required>false</required>
    <unique>false</unique>
    <description>Provider license number</description>
</CustomField>
```

## Validation Rules
```xml
✅ CORRECT:
<ValidationRule>
    <fullName>Email_Required</fullName>
    <active>true</active>
    <description>Email is required for all accounts</description>
    <errorConditionFormula>ISBLANK(Email)</errorConditionFormula>
    <errorMessage>Email is required</errorMessage>
</ValidationRule>
```

## Flows
- Use Screen Flows for user interaction
- Use Record-Triggered Flows for automation
- Use Scheduled Flows for batch processing
- Always add descriptions
- Test with bulk data (200+ records)
- Use fault paths for error handling

## Lightning Web Components
```
✅ CORRECT Structure:
lwc/
├── componentName/
│   ├── componentName.html
│   ├── componentName.js
│   ├── componentName.js-meta.xml
│   └── componentName.css
```

## Page Layouts
- Group related fields
- Use sections logically
- Required fields at top
- Related lists at bottom
- Mobile-optimized

## Reports & Dashboards
- Clear naming convention
- Organize in folders by department
- Add descriptions
- Set appropriate access levels
- Test with large data sets

## Common Mistakes to Avoid
❌ Modifying standard profiles
❌ Creating profiles instead of permission sets
❌ Not testing with Platform license
❌ Circular role hierarchies
❌ Missing permission dependencies
❌ Hardcoding IDs
❌ Not documenting purpose
❌ SOQL/DML in loops
❌ Missing field-level security
❌ Not bulkifying code
❌ Missing test classes
❌ Hardcoding URLs or credentials
❌ Not using Custom Metadata for configuration

## Checklist
- [ ] Naming follows conventions
- [ ] Description added
- [ ] License compatibility verified
- [ ] Role hierarchy correct
- [ ] Permissions minimal (least privilege)
- [ ] Dependencies documented
- [ ] Tested in target org
- [ ] Version controlled
- [ ] Field-level security configured
- [ ] Validation rules tested
- [ ] Flows tested with bulk data
- [ ] Page layouts mobile-optimized
- [ ] Reports have proper folder structure
- [ ] Custom metadata used for config
- [ ] All code has test coverage >75%
