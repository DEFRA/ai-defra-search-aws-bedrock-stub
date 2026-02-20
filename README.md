# ai-defra-search-aws-bedrock-stub

WireMock stub service to simulate AWS Bedrock API endpoints for local development and testing.

## Quick Start

Start the WireMock service using Docker Compose:

```bash
docker compose up -d
```

The service will be available at `http://localhost:8080`.

## Documentation

For detailed information about using the WireMock stub service, see [WIREMOCK_GUIDE.md](./WIREMOCK_GUIDE.md).

## Available Endpoints

- **Stub Endpoints**: `http://localhost:8080`
- **Admin API**: `http://localhost:8080/__admin`
- **Health Check**: `http://localhost:8080/__admin/health`

## Stub Configuration

Stub mappings are defined in `./wiremock/mappings/` and response files in `./wiremock/__files/`.

### Current Stubs

1. **Claude Converse API** - Simulates AWS Bedrock Claude model conversations
2. **Titan Embed Text V2 API** - Simulates AWS Bedrock text embedding

## Docker

### Build Image

```bash
docker build -t ai-defra-search-aws-bedrock-stub .
```

### Run Container

```bash
docker run -p 8080:8080 ai-defra-search-aws-bedrock-stub
```

# WireMock Stub Service Guide

This project includes a WireMock stub service to simulate AWS Bedrock API endpoints for local development and testing.

## Starting the Service

Start the WireMock service using Docker Compose:

```bash
docker compose up -d wiremock
```

Or start all services:

```bash
docker compose up -d
```

## Accessing WireMock

- **Stub Endpoints**: `http://localhost:8090`
- **Admin API**: `http://localhost:8090/__admin`
- **From Docker Network**: `http://wiremock:8080`

## Health Check

```bash
curl http://localhost:8090/__admin/health
```

## Available Stub Endpoints

### Understanding Priority Matching

WireMock uses priority-based matching to select responses when multiple mappings could match a request. Lower priority numbers are matched first (priority 1 before priority 2). This allows you to create specific responses for particular scenarios while having fallback responses for general cases.

All responses include a 2-second delay (`fixedDelayMilliseconds: 2000`) to simulate realistic API latency.

### 1. Claude Converse API

**Endpoint**: `POST /model/anthropic.claude-{model}/converse`

The Claude Converse API stub supports multiple conversation scenarios using priority-based pattern matching:

#### Simple Question - "What is UCD?" (Priority 2)

Matches simple user questions containing "What is UCD".

**Example Request**:
```bash
curl -X POST http://localhost:8090/model/anthropic.claude-3-5-sonnet-20241022-v2:0/converse \
  -H "Content-Type: application/x-amz-json-1.1" \
  -d '{
    "messages": [
      {
        "role": "user",
        "content": [{"text": "What is UCD?"}]
      }
    ]
  }'
```

**Response**:
```json
{
  "output": {
    "message": {
      "role": "assistant",
      "content": [
        {
          "text": "It's this really cool thing called User Centred Design"
        }
      ]
    }
  },
  "stopReason": "end_turn",
  "usage": {
    "inputTokens": 180,
    "outputTokens": 295,
    "totalTokens": 475
  }
}
```

#### Multi-turn Conversation - "Is it good practice?" (Priority 1)

Matches conversations with message history containing "Is it good practice" in the third message.

**Example Request**:
```bash
curl -X POST http://localhost:8090/model/anthropic.claude-3-5-sonnet-20241022-v2:0/converse \
  -H "Content-Type: application/x-amz-json-1.1" \
  -d '{
    "messages": [
      {
        "role": "user",
        "content": [{"text": "What is UCD?"}]
      },
      {
        "role": "assistant",
        "content": [{"text": "It'\''s this really cool thing called User Centred Design"}]
      },
      {
        "role": "user",
        "content": [{"text": "Is it good practice to use UCD?"}]
      }
    ]
  }'
```

**Response**:
```json
{
  "output": {
    "message": {
      "role": "assistant",
      "content": [
        {
          "text": "Absolutely, you'll produce much better software geared towards users needs"
        }
      ]
    }
  },
  "stopReason": "end_turn",
  "usage": {
    "inputTokens": 180,
    "outputTokens": 295,
    "totalTokens": 475
  }
}
```

### 2. Titan Embed Text V2 API

**Endpoint**: `POST /model/amazon.titan-embed-text-v2:0/invoke`

**Example Request**:
```bash
curl -X POST http://localhost:8090/model/amazon.titan-embed-text-v2:0/invoke \
  -H "Content-Type: application/json" \
  -d '{"inputText": "Sample text to embed"}'
```

**Response**: Returns `embed_response.json` with a 2-second delay

## Customizing Stubs

### Adding New Mappings

1. Create a new mapping file in `./wiremock/mappings/`:

```json
{
  "mappings": [
    {
      "name": "My Custom Stub",
      "priority": 1,
      "request": {
        "method": "POST",
        "urlPathPattern": "/model/.*",
        "bodyPatterns": [
          {
            "matchesJsonPath": "$.messages[?(@.role == 'user')]",
            "contains": "specific text"
          }
        ]
      },
      "response": {
        "status": 200,
        "bodyFileName": "my_response.json",
        "headers": {
          "Content-Type": "application/json"
        },
        "fixedDelayMilliseconds": 2000
      }
    }
  ]
}
```

**Key Fields**:
- `priority`: Lower numbers are matched first (1 before 2). Use this to create specific responses that take precedence over general ones.
- `bodyPatterns`: Array of patterns to match against the request body. Supports `matchesJsonPath` for JSON path queries and `contains` for text matching.
- `matchesJsonPath`: Uses JSONPath syntax to query the request body structure.
- `fixedDelayMilliseconds`: Adds realistic latency to responses.

2. Create the response file in `./wiremock/__files/my_response.json`

3. Restart WireMock:
```bash
docker compose restart wiremock
```

### Viewing Loaded Mappings

```bash
curl http://localhost:8090/__admin/mappings
```

### Viewing Request History

```bash
curl http://localhost:8090/__admin/requests
```

## Admin API

WireMock provides a powerful admin API for managing stubs:

- **List all mappings**: `GET /__admin/mappings`
- **View request journal**: `GET /__admin/requests`
- **Reset request journal**: `DELETE /__admin/requests`
- **Add new mapping**: `POST /__admin/mappings`
- **Health check**: `GET /__admin/health`

## Troubleshooting

### Check Container Status
```bash
docker compose ps
```

### View Logs
```bash
docker compose logs wiremock
```

### Follow Logs in Real-time
```bash
docker compose logs -f wiremock
```

### Verify Mappings are Loaded
```bash
curl http://localhost:8090/__admin/mappings | jq '.mappings | length'
```

## Resources

- [WireMock Documentation](https://wiremock.org/docs/)
- [WireMock Admin API](https://wiremock.org/docs/api/)
- [Request Matching](https://wiremock.org/docs/request-matching/)
- [Response Templating](https://wiremock.org/docs/response-templating/)

## Licence

THIS INFORMATION IS LICENSED UNDER THE CONDITIONS OF THE OPEN GOVERNMENT LICENCE found at:

<http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3>

The following attribution statement MUST be cited in your products and applications when using this information.

> Contains public sector information licensed under the Open Government licence v3

### About the licence

The Open Government Licence (OGL) was developed by the Controller of Her Majesty's Stationery Office (HMSO) to enable
information providers in the public sector to license the use and re-use of their information under a common open
licence.

It is designed to encourage use and re-use of information freely and flexibly, with only a few conditions.

```bash
git config --global core.autocrlf false
```

## API endpoints

| Endpoint             | Description                    |
| :------------------- | :----------------------------- |
| `GET: /health`       | Health                         |
| `GET: /example    `  | Example API (remove as needed) |
| `GET: /example/<id>` | Example API (remove as needed) |

## Development helpers

### Proxy

We are using forward-proxy which is set up by default. To make use of this: `import { fetch } from 'undici'` then
because of the `setGlobalDispatcher(new ProxyAgent(proxyUrl))` calls will use the ProxyAgent Dispatcher

If you are not using Wreck, Axios or Undici or a similar http that uses `Request`. Then you may have to provide the
proxy dispatcher:

To add the dispatcher to your own client:

```javascript
import { ProxyAgent } from 'undici'

return await fetch(url, {
  dispatcher: new ProxyAgent({
    uri: proxyUrl,
    keepAliveTimeout: 10,
    keepAliveMaxTimeout: 10
  })
})
```

## Licence

THIS INFORMATION IS LICENSED UNDER THE CONDITIONS OF THE OPEN GOVERNMENT LICENCE found at:

<http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3>

The following attribution statement MUST be cited in your products and applications when using this information.

> Contains public sector information licensed under the Open Government license v3

### About the licence

The Open Government Licence (OGL) was developed by the Controller of Her Majesty's Stationery Office (HMSO) to enable
information providers in the public sector to license the use and re-use of their information under a common open
licence.

It is designed to encourage use and re-use of information freely and flexibly, with only a few conditions.
